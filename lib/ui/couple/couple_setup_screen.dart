import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import 'couple_provider.dart';
import 'join_couple_screen.dart';

class CoupleSetupScreen extends StatelessWidget {
  const CoupleSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CoupleSetupView();
  }
}

class _CoupleSetupView extends StatelessWidget {
  const _CoupleSetupView();

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleCreateCouple(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coupleProvider = Provider.of<CoupleProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) return;

    final success = await coupleProvider.createCouple(user);
    if (!context.mounted) return;

    if (success) {
      await authProvider.checkAuthSession();
      if (!context.mounted) return;

      final inviteCode = coupleProvider.couple?.inviteCode ?? '';

      // Tampilkan Dialog Khusus untuk Bagikan & Salin Kode
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(
            'Ruang berhasil dibuat',
            style: AppText.display(26),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bagikan kode ini ke pasanganmu agar bisa bergabung.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: SelectableText(
                  inviteCode,
                  textAlign: TextAlign.center,
                  style: AppText.body(
                    32,
                    weight: FontWeight.bold,
                    letterSpacing: 6,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Salin'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: inviteCode));
                        AppSnack.show(
                          context,
                          'Kode berhasil disalin!',
                          type: AppSnackType.success,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Bagikan'),
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: 'Yuk gabung di ruang privat kita di PUFLUV! Masukkan kode undangan: $inviteCode',
                            subject: 'Undangan PUFLUV Space',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Lanjut ke beranda'),
            ),
          ],
        ),
      );

      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      AppSnack.show(
        context,
        coupleProvider.errorMessage ?? 'Gagal membuat couple space',
        type: AppSnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final coupleProvider = Provider.of<CoupleProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar: wordmark + logout (sama seperti Home)
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: AppBrand(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppColors.text, size: 20),
                      tooltip: 'Logout',
                      onPressed: () => _logout(context, authProvider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AppScreenHeading(
                  title: 'Halo, ${user?.name ?? 'User'}',
                  subtitle: 'Pilih salah satu cara untuk memulai ruang privat bersama pasanganmu.',
                ),
              ),
              const SizedBox(height: 32),
              _OptionCard(
                tag: 'BARU',
                title: 'Buat ruang baru',
                description: 'Dapatkan kode undangan untuk dibagikan ke pasanganmu.',
                loading: coupleProvider.isLoading,
                highlighted: true,
                onTap: coupleProvider.isLoading
                    ? null
                    : () => _handleCreateCouple(context),
              ),
              const SizedBox(height: 14),
              _OptionCard(
                tag: 'PUNYA KODE?',
                title: 'Gabung dengan kode undangan',
                description: 'Masukkan kode dari pasanganmu yang sudah membuat ruang.',
                onTap: coupleProvider.isLoading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const JoinCoupleScreen(),
                          ),
                        );
                      },
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: coupleProvider.isLoading
                      ? null
                      : () => _logout(context, authProvider),
                  child: Text(
                    'Keluar',
                    style: AppText.body(14, color: AppColors.muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu pilihan: gaya sama dengan kartu countdown di Home.
class _OptionCard extends StatelessWidget {
  final String tag;
  final String title;
  final String description;
  final bool loading;
  final bool highlighted;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.tag,
    required this.title,
    required this.description,
    this.loading = false,
    this.highlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: highlighted
              ? AppColors.accent.withValues(alpha: 0.35)
              : AppColors.cardBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tag, style: AppText.label()),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: AppText.body(18, weight: FontWeight.w500, height: 1.25),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppText.body(13, color: AppColors.muted, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
