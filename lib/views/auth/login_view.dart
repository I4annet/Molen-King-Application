import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../shared/widgets.dart';
import 'register_view.dart';
import '../cashier/cashier_main_view.dart';
import '../admin/admin_main_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isDark = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AppStateProvider>(context, listen: false);
    final success = await provider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        final role = provider.currentUser?.role;
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminMainView()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CashierMainView()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Login Gagal'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Scaffold(
      body: ArtisanBackground(
        isDark: isDark,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Theme toggler and connection status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<AppStateProvider>(
                          builder: (context, state, _) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: state.isSimulationMode
                                    ? AppColors.goldenCaramel.withOpacity(0.2)
                                    : AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: state.isSimulationMode
                                      ? AppColors.goldenCaramel
                                      : AppColors.success,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: state.isSimulationMode
                                        ? AppColors.goldenCaramel
                                        : AppColors.success,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    state.isSimulationMode
                                        ? 'Mode Simulasi (Lokal)'
                                        : 'Online (Supabase)',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark
                                ? AppColors.royalHoneyGold
                                : AppColors.goldenCaramel,
                          ),
                          onPressed: () {
                            setState(() {
                              _isDark = !_isDark;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Logo & Brand Header
                    Center(
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.royalHoneyGold.withOpacity(0.15),
                          border: Border.all(
                            color: AppColors.royalHoneyGold,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.royalHoneyGold.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          size: 48,
                          color: AppColors.royalHoneyGold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Molen King',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.royalHoneyGold
                              : AppColors.goldenCaramel,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(
                                isDark ? 0.5 : 0.1,
                              ),
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Premium Artisan Molen Cashier System',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Form Card
                    PremiumCard(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Masuk Akun',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Silakan masuk untuk mengelola toko molen.',
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          PremiumTextField(
                            controller: _emailController,
                            labelText: 'Alamat Email',
                            hintText: 'email@domain.com',
                            prefixIcon: Icons.email_outlined,
                            isDark: isDark,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Email wajib diisi';
                              if (!v.contains('@'))
                                return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          PremiumTextField(
                            controller: _passwordController,
                            labelText: 'Kata Sandi',
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            isPassword: _obscurePassword,
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: isDark
                                    ? AppColors.royalHoneyGold.withOpacity(0.8)
                                    : AppColors.goldenCaramel.withOpacity(0.8),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Sandi wajib diisi';
                              if (v.length < 6)
                                return 'Sandi minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Consumer<AppStateProvider>(
                            builder: (context, state, _) {
                              return PremiumButton(
                                text: 'Masuk Sekarang',
                                isInitializing: state.isLogginIn,
                                onPressed: _handleLogin,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Navigation to register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum memiliki akun? ',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterView(isDark: isDark),
                              ),
                            );
                          },
                          child: Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.royalHoneyGold
                                  : AppColors.goldenCaramel,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Test credentials note for ease of use
                    Consumer<AppStateProvider>(
                      builder: (context, state, _) {
                        if (state.isSimulationMode) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.royalHoneyGold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.royalHoneyGold.withOpacity(
                                  0.2,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '💡 Akun Uji Coba Mode Simulasi:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.softButterCream
                                        : AppColors.goldenCaramel,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '• Admin/Owner: admin@molenking.com | 123456\n• Kasir/Karyawan: kasir@molenking.com | 123456',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textColor.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
