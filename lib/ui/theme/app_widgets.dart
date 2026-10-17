import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Wordmark "PUFLUV" kecil berspasi lebar, sama seperti di top bar Home.
class AppBrand extends StatelessWidget {
  const AppBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'PUFLUV',
      style: AppText.body(
        12,
        weight: FontWeight.w500,
        letterSpacing: 4,
        color: AppColors.accent,
      ),
    );
  }
}

/// Judul besar (Fraunces) + subjudul untuk layar auth / setup.
class AppScreenHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const AppScreenHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.display(38)),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: AppText.body(14, color: AppColors.muted, height: 1.45),
        ),
      ],
    );
  }
}

/// Label 12px di atas sebuah kolom, seperti "Nama tag" pada desain.
class AppFieldShell extends StatelessWidget {
  final String? label;
  final Widget child;

  const AppFieldShell({super.key, this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    if (label == null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: AppText.fieldLabel()),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Dekorasi kolom input: radius 14, border putih 14%, fokus berwarna accent.
InputDecoration appInputDecoration({String? hint, Widget? suffixIcon, int maxLines = 1}) {
  OutlineInputBorder border(Color color, {double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: AppText.body(15, color: AppColors.hint),
    filled: true,
    fillColor: AppColors.surface,
    suffixIcon: suffixIcon,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: maxLines > 1 ? 14 : 15,
    ),
    border: border(AppColors.outline),
    enabledBorder: border(AppColors.outline),
    focusedBorder: border(AppColors.accent, width: 1.2),
    errorBorder: border(AppColors.danger.withValues(alpha: 0.7)),
    focusedErrorBorder: border(AppColors.danger, width: 1.2),
    errorStyle: AppText.body(12, color: AppColors.danger),
  );
}

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextStyle? style;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.style,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppFieldShell(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        textCapitalization: textCapitalization,
        textAlign: textAlign,
        style: style ?? AppText.body(15),
        cursorColor: AppColors.accent,
        validator: validator,
        decoration: appInputDecoration(
          hint: hint,
          suffixIcon: suffixIcon,
          maxLines: maxLines,
        ),
      ),
    );
  }
}

/// Tombol utama: pill penuh, latar accent, teks gelap ("Simpan tag").
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          // Saat loading tetap tampil penuh supaya spinner terlihat jelas.
          disabledBackgroundColor:
              AppColors.accent.withValues(alpha: loading ? 1.0 : 0.35),
          disabledForegroundColor: AppColors.onAccent,
          shape: const StadiumBorder(),
          textStyle: AppText.body(15, weight: FontWeight.w500),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onAccent,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Tombol sekunder: pill outline tipis, teks terang.
class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.outline),
          shape: const StadiumBorder(),
          textStyle: AppText.body(15, weight: FontWeight.w500),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Kartu permukaan: #181B22, border tipis, radius 24 (kartu countdown Home).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}

/// Lingkaran ikon (surface + border) untuk empty state / error state.
class AppIconBadge extends StatelessWidget {
  final IconData icon;

  const AppIconBadge({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Icon(icon, color: AppColors.accent, size: 30),
    );
  }
}

enum AppSnackType { info, success, error }

/// SnackBar seragam: kartu gelap melayang dengan ikon status.
class AppSnack {
  AppSnack._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackType type = AppSnackType.info,
  }) {
    final IconData icon;
    final Color color;
    switch (type) {
      case AppSnackType.success:
        icon = Icons.check_circle_outline_rounded;
        color = AppColors.accent;
        break;
      case AppSnackType.error:
        icon = Icons.error_outline_rounded;
        color = AppColors.danger;
        break;
      case AppSnackType.info:
        icon = Icons.info_outline_rounded;
        color = AppColors.muted;
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: AppText.body(14))),
          ],
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: Duration(seconds: type == AppSnackType.error ? 4 : 2),
      ),
    );
  }
}
