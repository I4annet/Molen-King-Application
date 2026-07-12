import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../shared/widgets.dart';
import '../auth/login_view.dart';
import 'admin_dashboard_view.dart';
import 'admin_reports_view.dart';
import 'admin_attendance_view.dart';
import 'admin_stock_view.dart';

class AdminMainView extends StatefulWidget {
  const AdminMainView({super.key});

  @override
  State<AdminMainView> createState() => _AdminMainViewState();
}

class _AdminMainViewState extends State<AdminMainView> {
  int _currentIndex = 0;
  bool _isDark = true;

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

    final List<Widget> tabs = [
      AdminDashboardView(isDark: isDark),
      AdminReportsView(isDark: isDark),
      AdminAttendanceView(isDark: isDark),
      AdminStockView(isDark: isDark),
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
                        border: Border.all(
                          color: AppColors.goldenCaramel,
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors.goldenCaramel.withOpacity(
                          0.1,
                        ),
                        radius: 22,
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: AppColors.goldenCaramel,
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
                            user?.name ?? 'Pemilik',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Owner / Admin • Asal: ${user?.origin ?? '-'}',
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
                        color: isDark
                            ? AppColors.royalHoneyGold
                            : AppColors.goldenCaramel,
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

              const Divider(
                color: AppColors.sageMint,
                height: 1,
                thickness: 0.5,
              ),

              // Subviews
              Expanded(
                child: provider.isInitializing
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.royalHoneyGold,
                        ),
                      )
                    : tabs[_currentIndex],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.royalHoneyGold.withOpacity(0.1)
                  : AppColors.sageMint,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: isDark
              ? AppColors.espressoDark
              : AppColors.ivoryCream,
          selectedItemColor: AppColors.royalHoneyGold,
          unselectedItemColor: textColor.withOpacity(0.4),
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.co_present_outlined),
              activeIcon: Icon(Icons.co_present),
              label: 'Absensi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warehouse_outlined),
              activeIcon: Icon(Icons.warehouse),
              label: 'Stok',
            ),
          ],
        ),
      ),
    );
  }
}
