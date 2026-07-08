import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state_provider.dart';
import '../../models/attendance_model.dart';
import '../shared/widgets.dart';
import '../auth/login_view.dart';
import 'cashier_transaction_view.dart';
import 'cashier_stock_view.dart';
import 'cashier_expense_view.dart';

class CashierMainView extends StatefulWidget {
  const CashierMainView({super.key});

  @override
  State<CashierMainView> createState() => _CashierMainViewState();
}

class _CashierMainViewState extends State<CashierMainView> {
  int _currentIndex = 0;
  bool _isDark = true;
  String _attendanceStatus = 'present'; // 'present', 'sick', 'leave'
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _handleCheckIn(AppStateProvider provider) async {
    final statusText = _attendanceStatus;
    final reason = _reasonController.text.trim();

    if ((statusText == 'sick' || statusText == 'leave') && reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alasan sakit / izin wajib diisi!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await provider.checkIn(statusText, reason.isNotEmpty ? reason : null);
    if (mounted && success) {
      _reasonController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusText == 'present'
              ? 'Check-In Berhasil! Akses sistem terbuka.'
              : 'Status absensi berhasil dicatat!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleCheckOut(AppStateProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDark ? AppColors.cardDark : AppColors.cardLight,
        title: Text(
          'Check-Out Shift?',
          style: TextStyle(
            color: _isDark ? AppColors.textLight : AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menyelesaikan shift dan Check-Out dari sistem?',
          style: TextStyle(
            color: (_isDark ? AppColors.textLight : AppColors.textDark).withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldenCaramel),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Check-Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await provider.checkOut();
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-Out Berhasil! Shift Anda telah diakhiri.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _handleLogout(AppStateProvider provider) async {
    await provider.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final user = provider.currentUser;
    final isDark = _isDark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    // Check-in constraints
    // If lastCheckIn is not null and lastCheckOut is null, the user is checked in
    final isCheckedIn = user?.lastCheckIn != null && user?.lastCheckOut == null;
    // Active means checked in as 'present' (ready to sell/manage stock)
    final isActive = isCheckedIn && (user?.isActive ?? false);

    // Sub-views tabs list (Only unlocked if isActive is true)
    final List<Widget> tabs = [
      CashierTransactionView(isDark: isDark),
      CashierStockView(isDark: isDark),
      CashierExpenseView(isDark: isDark),
    ];

    return Scaffold(
      body: ArtisanBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.royalHoneyGold, width: 1.5),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors.royalHoneyGold.withOpacity(0.1),
                        radius: 22,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.royalHoneyGold,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Karyawan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Karyawan / Kasir • Asal: ${user?.origin ?? '-'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: isDark ? AppColors.royalHoneyGold : AppColors.goldenCaramel,
                      ),
                      onPressed: () => setState(() => _isDark = !_isDark),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      onPressed: () => _handleLogout(provider),
                      tooltip: 'Keluar Akun',
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.sageMint, height: 1, thickness: 0.5),

              // Main content body
              Expanded(
                child: () {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.royalHoneyGold),
                    );
                  }

                  // 1. LOCKED SYSTEM SCREEN (IF NOT CHECKED IN AT ALL)
                  if (!isCheckedIn) {
                    return _buildLockedCheckInScreen(provider, textColor);
                  }

                  // 2. ABSENCE RESTRICTION SCREEN (IF CHECKED IN BUT SICK / ON LEAVE)
                  if (isCheckedIn && !isActive) {
                    return _buildSickLeaveRestrictionScreen(provider, textColor);
                  }

                  // 3. UNLOCKED CASHER SYSTEM
                  return tabs[_currentIndex];
                }(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: (isCheckedIn && isActive)
          ? Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.royalHoneyGold.withOpacity(0.1) : AppColors.sageMint,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                backgroundColor: isDark ? AppColors.espressoDark : AppColors.ivoryCream,
                selectedItemColor: AppColors.royalHoneyGold,
                unselectedItemColor: textColor.withOpacity(0.4),
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.point_of_sale_outlined),
                    activeIcon: Icon(Icons.point_of_sale),
                    label: 'Kasir',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_2_outlined),
                    activeIcon: Icon(Icons.inventory_2),
                    label: 'Stok',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.price_change_outlined),
                    activeIcon: Icon(Icons.price_change),
                    label: 'Pengeluaran',
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // Widget: Locked Check-In Panel
  Widget _buildLockedCheckInScreen(AppStateProvider provider, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Icon(
            Icons.lock_clock,
            size: 80,
            color: _isDark ? AppColors.softButterCream : AppColors.goldenCaramel,
          ),
          const SizedBox(height: 20),
          Text(
            'Sistem Kasir Terkunci',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Untuk mengakses fitur penjualan, stok, dan pencatatan pengeluaran, silakan lakukan Check-In kehadiran harian Anda terlebih dahulu.',
            style: TextStyle(
              fontSize: 13,
              color: textColor.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          PremiumCard(
            isDark: _isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Form Absensi Harian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Status radios / options
                Text(
                  'Status Kehadiran Hari Ini:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _attendanceStatus,
                  dropdownColor: _isDark ? AppColors.cardDark : AppColors.cardLight,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.assignment_ind_outlined,
                      color: _isDark ? AppColors.royalHoneyGold : AppColors.goldenCaramel,
                    ),
                    filled: true,
                    fillColor: _isDark
                        ? AppColors.espressoDark.withOpacity(0.6)
                        : AppColors.ivoryCream.withOpacity(0.6),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isDark ? AppColors.royalHoneyGold.withOpacity(0.2) : AppColors.sageMint,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.royalHoneyGold),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'present', child: Text('Hadir (Siap Kerja)')),
                    DropdownMenuItem(value: 'sick', child: Text('Sakit')),
                    DropdownMenuItem(value: 'leave', child: Text('Izin (Keperluan Lain)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _attendanceStatus = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Show reason text field if sick/leave
                if (_attendanceStatus != 'present') ...[
                  PremiumTextField(
                    controller: _reasonController,
                    labelText: 'Keterangan / Alasan Halangan',
                    hintText: 'Tuliskan alasan sakit atau keperluan lainnya',
                    prefixIcon: Icons.edit_note,
                    isDark: _isDark,
                    validator: (v) => (v == null || v.isEmpty) ? 'Alasan wajib diisi jika berhalangan' : null,
                  ),
                  const SizedBox(height: 20),
                ],

                PremiumButton(
                  text: 'Check-In Sekarang',
                  isLoading: provider.isLoading,
                  onPressed: () => _handleCheckIn(provider),
                  icon: Icons.login_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Sick/Leave Access Restriction Panel
  Widget _buildSickLeaveRestrictionScreen(AppStateProvider provider, Color textColor) {
    final lastLog = provider.attendanceLogs.firstWhere(
      (l) => l.userId == provider.currentUser?.id,
      orElse: () => AttendanceModel(
        id: '',
        userId: '',
        userName: '',
        date: DateTime.now(),
        checkInTime: DateTime.now(),
        status: 'present',
      ),
    );
    final statusString = lastLog.status == 'sick' ? 'SAKIT' : 'IZIN';
    final formatter = DateFormat('dd MMMM yyyy, HH:mm');

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            lastLog.status == 'sick' ? Icons.sick : Icons.assignment_late,
            size: 90,
            color: AppColors.goldenCaramel,
          ),
          const SizedBox(height: 20),
          Text(
            'Akses Terbatas ($statusString)',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          PremiumCard(
            isDark: _isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Absensi:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Waktu Check-In: ${formatter.format(lastLog.checkInTime)}',
                  style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13),
                ),
                Text(
                  '• Status: $statusString',
                  style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13),
                ),
                if (lastLog.reason != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '• Keterangan: "${lastLog.reason}"',
                    style: TextStyle(
                      color: _isDark ? AppColors.softButterCream : AppColors.goldenCaramel,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sistem dikunci karena Anda melaporkan status berhalangan hadir. Anda dapat mengakhiri shift absensi ini untuk membuka kembali formulir Check-In jika salah input, atau keluar dari akun Anda.',
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PremiumButton(
            text: 'Check-Out Shift & Batalkan',
            isSecondary: true,
            isLoading: provider.isLoading,
            onPressed: () => _handleCheckOut(provider),
            icon: Icons.cancel_outlined,
          ),
        ],
      ),
    );
  }
}
