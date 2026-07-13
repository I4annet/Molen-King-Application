import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/widgets.dart';

class RegisterView extends StatefulWidget {
  final bool isDark;

  const RegisterView({super.key, required this.isDark});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _originController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'cashier'; // 'cashier' or 'admin'
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _originController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.register(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      phone: _phoneController.text,
      origin: _originController.text,
      role: _selectedRole,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi Berhasil! Silakan masuk.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Registrasi Gagal'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daftar Baru',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: ArtisanBackground(
        isDark: isDark,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Gabung Molen King',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.royalHoneyGold
                            : AppColors.goldenCaramel,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Buat akun baru untuk mulai mengakses sistem kasir digital.',
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),

                    PremiumCard(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Role Selector Selection
                          Text(
                            'Pilih Peran Akun',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Kasir / Karyawan'),
                                  selected: _selectedRole == 'cashier',
                                  onSelected: (selected) {
                                    if (selected)
                                      setState(() => _selectedRole = 'cashier');
                                  },
                                  selectedColor: AppColors.royalHoneyGold,
                                  backgroundColor: isDark
                                      ? AppColors.espressoDark
                                      : AppColors.ivoryCream,
                                  labelStyle: TextStyle(
                                    color: _selectedRole == 'cashier'
                                        ? Colors.white
                                        : textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Admin / Pemilik'),
                                  selected: _selectedRole == 'admin',
                                  onSelected: (selected) {
                                    if (selected)
                                      setState(() => _selectedRole = 'admin');
                                  },
                                  selectedColor: AppColors.goldenCaramel,
                                  backgroundColor: isDark
                                      ? AppColors.espressoDark
                                      : AppColors.ivoryCream,
                                  labelStyle: TextStyle(
                                    color: _selectedRole == 'admin'
                                        ? Colors.white
                                        : textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          PremiumTextField(
                            controller: _nameController,
                            labelText: 'Nama Lengkap',
                            hintText: 'Masukkan nama lengkap',
                            prefixIcon: Icons.person_outline,
                            isDark: isDark,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Nama wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          PremiumTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'nama@domain.com',
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
                            controller: _phoneController,
                            labelText: 'Nomor HP',
                            hintText: '08xxxxxxxxxx',
                            prefixIcon: Icons.phone_android_outlined,
                            isDark: isDark,
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Nomor HP wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          PremiumTextField(
                            controller: _originController,
                            labelText: 'Asal Daerah / Kota',
                            hintText: 'Yogyakarta',
                            prefixIcon: Icons.location_city_outlined,
                            isDark: isDark,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Asal daerah wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          PremiumTextField(
                            controller: _passwordController,
                            labelText: 'Kata Sandi Baru',
                            hintText: 'Minimal 6 karakter',
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
                          const SizedBox(height: 28),
                          Consumer<AuthProvider>(
                            builder: (context, state, _) {
                              return PremiumButton(
                                text: 'Daftar Sekarang',
                                isInitializing: state.isLoading,
                                onPressed: _handleRegister,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
