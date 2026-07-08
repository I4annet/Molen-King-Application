import 'package:flutter/material.dart';

// --- COLOR PALETTE (PREMIUM ARTISAN) ---
class AppColors {
  static const Color royalHoneyGold = Color(0xFFD89B2D);
  static const Color goldenCaramel = Color(0xFFB86A24);
  static const Color softButterCream = Color(0xFFF4D36A);
  static const Color espressoDark = Color(0xFF2B241E);
  static const Color ivoryCream = Color(0xFFF8F3E8);
  static const Color sageMint = Color(0xFFC7D8C3);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color textLight = Color(0xFFFBF9F6);
  static const Color textDark = Color(0xFF3E332A);
  static const Color cardDark = Color(0xFF382F27);
  static const Color cardLight = Color(0xFFFFFFFF);
}

// --- GLASSMORPHIC & ARTISAN CONTAINERS ---
class PremiumCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isDark;
  final Border? border;
  final List<BoxShadow>? shadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.isDark = true,
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withOpacity(0.85)
            : AppColors.cardLight.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: border ??
            Border.all(
              color: isDark
                  ? AppColors.royalHoneyGold.withOpacity(0.15)
                  : AppColors.sageMint.withOpacity(0.4),
              width: 1.5,
            ),
        boxShadow: shadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
      ),
      child: child,
    );
  }
}

// --- PREMIUM INPUT FIELD ---
class PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isDark;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const PremiumTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.isDark = true,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final hintColor = isDark
        ? AppColors.textLight.withOpacity(0.4)
        : AppColors.textDark.withOpacity(0.4);

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: isDark
              ? AppColors.royalHoneyGold.withOpacity(0.8)
              : AppColors.goldenCaramel.withOpacity(0.8),
          fontWeight: FontWeight.w600,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(
          prefixIcon,
          color: isDark ? AppColors.royalHoneyGold : AppColors.goldenCaramel,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? AppColors.espressoDark.withOpacity(0.6)
            : AppColors.ivoryCream.withOpacity(0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.royalHoneyGold.withOpacity(0.2)
                : AppColors.sageMint,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.royalHoneyGold,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}

// --- PREMIUM BUTTONS ---
class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final bool isLoading;
  final IconData? icon;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isSecondary
        ? const LinearGradient(
            colors: [AppColors.goldenCaramel, Color(0xFF9E5410)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [AppColors.royalHoneyGold, Color(0xFFB47D1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isSecondary ? AppColors.goldenCaramel : AppColors.royalHoneyGold)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.textLight,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.textLight, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// --- APP GRADIENT BACKGROUND ---
class ArtisanBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const ArtisanBackground({
    super.key,
    required this.child,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.espressoDark : AppColors.ivoryCream,
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  AppColors.espressoDark,
                  Color(0xFF1E1814),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [
                  AppColors.ivoryCream,
                  Color(0xFFEFE8DA),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
      child: child,
    );
  }
}
