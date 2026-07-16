import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/user_model.dart';
import '../../models/attendance_model.dart';
import '../shared/widgets.dart';

class AdminAttendanceView extends StatefulWidget {
  final bool isDark;
  const AdminAttendanceView({super.key, required this.isDark});

  @override
  State<AdminAttendanceView> createState() => _AdminAttendanceViewState();
}

class _AdminAttendanceViewState extends State<AdminAttendanceView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final dateFormatter = DateFormat('dd/MM/yyyy');
  final timeFormatter = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Attendance report calculator
  Map<String, Map<String, int>> _calculateAttendanceSummary(
    List<AttendanceModel> logs,
    List<UserModel> cashiers,
    bool isWeekly,
  ) {
    final Map<String, Map<String, int>> summaries = {};

    // Initialize
    for (var c in cashiers) {
      summaries[c.id] = {'present': 0, 'sick': 0, 'leave': 0, 'total': 0};
    }

    final now = DateTime.now();
    DateTime startRange;
    if (isWeekly) {
      // 7 days ago
      startRange = now.subtract(const Duration(days: 7));
    } else {
      // 30 days ago
      startRange = now.subtract(const Duration(days: 30));
    }

    final periodLogs = logs
        .where((l) => l.checkInTime.isAfter(startRange))
        .toList();

    for (var log in periodLogs) {
      if (summaries.containsKey(log.userId)) {
        final current = summaries[log.userId]!;
        if (log.status == 'present') {
          current['present'] = (current['present'] ?? 0) + 1;
        } else if (log.status == 'sick') {
          current['sick'] = (current['sick'] ?? 0) + 1;
        } else if (log.status == 'leave') {
          current['leave'] = (current['leave'] ?? 0) + 1;
        }
        current['total'] = (current['total'] ?? 0) + 1;
      }
    }

    return summaries;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final textColor = widget.isDark ? AppColors.textLight : AppColors.textDark;

    final cashiers = authProvider.users
        .where((u) => u.role == 'cashier')
        .toList();
    final activeCashiers = cashiers.where((u) => u.isActive).toList();

    final weeklySummaries = _calculateAttendanceSummary(
      attendanceProvider.attendanceLogs,
      cashiers,
      true,
    );
    final monthlySummaries = _calculateAttendanceSummary(
      attendanceProvider.attendanceLogs,
      cashiers,
      false,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Absensi & Kehadiran Karyawan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau status karyawan aktif dan lihat laporan kehadiran.',
              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
            ),
            const SizedBox(height: 16),

            // Active cashiers banner
            PremiumCard(
              isDark: widget.isDark,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Karyawan Aktif Saat Ini:',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeCashiers.isEmpty
                              ? 'Tidak ada karyawan aktif di toko'
                              : activeCashiers.map((u) => u.name).join(', '),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: activeCashiers.isEmpty
                                ? textColor.withOpacity(0.8)
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${activeCashiers.length} Aktif',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.royalHoneyGold,
              unselectedLabelColor: textColor.withOpacity(0.5),
              indicatorColor: AppColors.royalHoneyGold,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Daftar Karyawan'),
                Tab(text: 'Laporan Kehadiran'),
              ],
            ),
            const SizedBox(height: 12),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: LIST OF EMPLOYEES
                  RefreshIndicator(
                    onRefresh: () async {
                      await Provider.of<AuthProvider>(context, listen: false).loadUsers();
                      await Provider.of<AttendanceProvider>(context, listen: false).loadAttendanceLogs();
                    },
                    color: AppColors.royalHoneyGold,
                    child: cashiers.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: 250,
                                child: Center(
                                  child: Text(
                                    'Belum ada karyawan terdaftar.',
                                    style: TextStyle(color: textColor.withOpacity(0.5)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: cashiers.length,
                            itemBuilder: (context, index) {
                              final c = cashiers[index];
                              return PremiumCard(
                                  isDark: widget.isDark,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: c.isActive
                                            ? AppColors.success.withOpacity(0.15)
                                            : textColor.withOpacity(0.1),
                                        child: Icon(
                                          Icons.person,
                                          color: c.isActive
                                              ? AppColors.success
                                              : textColor.withOpacity(0.6),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: c.isActive
                                                    ? AppColors.success.withOpacity(0.15)
                                                    : Colors.grey.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                c.isActive ? 'Aktif' : 'Off Shift',
                                                style: TextStyle(
                                                  color: c.isActive
                                                      ? AppColors.success
                                                      : Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility_outlined),
                                            color: AppColors.royalHoneyGold,
                                            iconSize: 22,
                                            onPressed: () => _showEmployeeDetails(c),
                                            tooltip: 'Detail Karyawan',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            color: AppColors.error,
                                            iconSize: 22,
                                            onPressed: () => _handleDeleteEmployee(authProvider, c),
                                            tooltip: 'Hapus Karyawan',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),

                  // TAB 2: ATTENDANCE REPORTS
                  RefreshIndicator(
                    onRefresh: () async {
                      await Provider.of<AttendanceProvider>(context, listen: false).loadAttendanceLogs();
                      await Provider.of<AuthProvider>(context, listen: false).loadUsers();
                    },
                    color: AppColors.royalHoneyGold,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Weekly Report Section
                          _buildReportSectionTitle(
                            'Laporan Kehadiran Mingguan (7 Hari Terakhir)',
                            textColor,
                          ),
                          const SizedBox(height: 10),
                          _buildReportList(cashiers, weeklySummaries),

                          const SizedBox(height: 24),

                          // Monthly Report Section
                          _buildReportSectionTitle(
                            'Laporan Kehadiran Bulanan (30 Hari Terakhir)',
                            textColor,
                          ),
                          const SizedBox(height: 10),
                          _buildReportList(cashiers, monthlySummaries),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showAddEmployeeDialog(context, authProvider),
              backgroundColor: AppColors.royalHoneyGold,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person_add_alt_1),
            )
          : null,
    );
  }

  Widget _buildReportSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildReportList(
    List<UserModel> cashiers,
    Map<String, Map<String, int>> summaries,
  ) {
    if (cashiers.isEmpty) {
      return PremiumCard(
        isDark: widget.isDark,
        child: const Center(child: Text('Belum ada data absensi.')),
      );
    }

    return Column(
      children: cashiers.map((c) {
        final sum =
            summaries[c.id] ??
            {'present': 0, 'sick': 0, 'leave': 0, 'total': 0};
        final present = sum['present'] ?? 0;
        final sick = sum['sick'] ?? 0;
        final leave = sum['leave'] ?? 0;

        final textColor = widget.isDark
            ? AppColors.textLight
            : AppColors.textDark;

        return PremiumCard(
          isDark: widget.isDark,
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  c.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildAbsenceTag('Hadir', present, AppColors.success),
                  const SizedBox(width: 6),
                  _buildAbsenceTag('Izin', leave, AppColors.royalHoneyGold),
                  const SizedBox(width: 6),
                  _buildAbsenceTag('Sakit', sick, AppColors.error),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAbsenceTag(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10,
              color: widget.isDark
                  ? AppColors.textLight.withOpacity(0.8)
                  : AppColors.textDark.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context, AuthProvider authProvider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final originController = TextEditingController();
    final passwordController = TextEditingController();
    bool isObscured = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final isDark = widget.isDark;
            final dialogTextColor = isDark ? AppColors.textLight : AppColors.textDark;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              title: Text(
                'Tambah Karyawan Baru',
                style: TextStyle(
                  color: dialogTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PremiumTextField(
                          controller: nameController,
                          labelText: 'Nama Lengkap',
                          hintText: 'Nama Karyawan',
                          prefixIcon: Icons.person_outline,
                          isDark: isDark,
                          validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        PremiumTextField(
                          controller: emailController,
                          labelText: 'Email',
                          hintText: 'karyawan@email.com',
                          prefixIcon: Icons.email_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                        ),
                        const SizedBox(height: 12),
                        PremiumTextField(
                          controller: phoneController,
                          labelText: 'No. HP',
                          hintText: '08123456789',
                          prefixIcon: Icons.phone_android_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.isEmpty) ? 'No. HP wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        PremiumTextField(
                          controller: originController,
                          labelText: 'Kota Asal',
                          hintText: 'Surabaya / Malang',
                          prefixIcon: Icons.location_city_outlined,
                          isDark: isDark,
                          validator: (v) => (v == null || v.isEmpty) ? 'Asal kota wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        PremiumTextField(
                          controller: passwordController,
                          labelText: 'Kata Sandi',
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: Icons.lock_outline,
                          isPassword: isObscured,
                          isDark: isDark,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscured ? Icons.visibility_off : Icons.visibility,
                              color: dialogTextColor.withOpacity(0.5),
                            ),
                            onPressed: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Kata sandi minimal 6 karakter'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    nameController.dispose();
                    emailController.dispose();
                    phoneController.dispose();
                    originController.dispose();
                    passwordController.dispose();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.royalHoneyGold,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      final name = nameController.text.trim();
                      final phone = phoneController.text.trim();
                      final origin = originController.text.trim();

                      nameController.dispose();
                      emailController.dispose();
                      phoneController.dispose();
                      originController.dispose();
                      passwordController.dispose();

                      Navigator.pop(dialogContext);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mendaftarkan karyawan baru...')),
                      );

                      final success = await authProvider.register(
                        email: email,
                        password: password,
                        name: name,
                        phone: phone,
                        origin: origin,
                        role: 'cashier',
                      );

                      if (success) {
                        await authProvider.loadUsers();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registrasi karyawan berhasil!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                authProvider.errorMessage ?? 'Gagal mendaftarkan karyawan',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEmployeeDetails(UserModel user) {
    final formatter = DateFormat('dd MMMM yyyy, HH:mm');
    final isDark = widget.isDark;
    final dialogTextColor = isDark ? AppColors.textLight : AppColors.textDark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          title: Row(
            children: [
              const Icon(Icons.badge_outlined, color: AppColors.royalHoneyGold),
              const SizedBox(width: 10),
              Text(
                'Detail Karyawan',
                style: TextStyle(
                  color: dialogTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Nama', user.name, dialogTextColor),
                  _buildDetailRow('Email', user.email, dialogTextColor),
                  _buildDetailRow('No. HP', user.phone, dialogTextColor),
                  _buildDetailRow('Kota Asal', user.origin, dialogTextColor),
                  _buildDetailRow(
                    'Status Shift',
                    user.isActive ? 'Aktif (On Duty)' : 'Off Shift',
                    dialogTextColor,
                    valueColor: user.isActive ? AppColors.success : Colors.grey,
                  ),
                  _buildDetailRow(
                    'Check-In Terakhir',
                    user.lastCheckIn != null ? formatter.format(user.lastCheckIn!) : '-',
                    dialogTextColor,
                  ),
                  _buildDetailRow(
                    'Check-Out Terakhir',
                    user.lastCheckOut != null ? formatter.format(user.lastCheckOut!) : '-',
                    dialogTextColor,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeleteEmployee(AuthProvider authProvider, UserModel user) async {
    final isDark = widget.isDark;
    final dialogTextColor = isDark ? AppColors.textLight : AppColors.textDark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          title: Text(
            'Hapus Karyawan?',
            style: TextStyle(
              color: dialogTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus profil "${user.name}" dari sistem?',
            style: TextStyle(
              color: dialogTextColor.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menghapus ${user.name}...')),
      );

      final success = await authProvider.deleteUser(user.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Karyawan berhasil dihapus!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Gagal menghapus karyawan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
