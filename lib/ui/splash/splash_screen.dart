import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../couple/couple_setup_screen.dart';
import '../home/home_screen.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    setState(() {
      _hasError = false;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Pasang timeout 5 detik agar splash tidak hang/blackscreen jika Firebase/jaringan lambat
      await authProvider.checkAuthSession().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Auth session check timed out after 5s');
        },
      );
    } catch (e) {
      debugPrint('Error during session check: $e');
    }

    if (!mounted) return;

    if (authProvider.status == AuthStatus.authenticated) {
      final user = authProvider.user;
      if (user != null && user.coupleId != null && user.coupleId!.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CoupleSetupScreen()),
        );
      }
    } else if (authProvider.status == AuthStatus.loadFailed) {
      // Jaringan lambat / profil gagal dimuat sementara sesi Firebase masih ada (H3)
      setState(() {
        _hasError = true;
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return _buildErrorState(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          builder: (context, value, child) =>
              Opacity(opacity: value, child: child),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Padding kiri = letterSpacing, supaya wordmark benar-benar di tengah.
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  'PUFLUV',
                  style: AppText.body(
                    14,
                    weight: FontWeight.w500,
                    letterSpacing: 8,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ruang privat berdua',
                style: AppText.body(13, color: AppColors.muted),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: AppIconBadge(icon: Icons.wifi_off_rounded),
                ),
                const SizedBox(height: 24),
                Text(
                  'Gagal memuat profil',
                  textAlign: TextAlign.center,
                  style: AppText.body(18, weight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Koneksi internet lambat atau terputus saat memeriksa sesi login.',
                  textAlign: TextAlign.center,
                  style: AppText.body(14, color: AppColors.muted, height: 1.45),
                ),
                const SizedBox(height: 28),
                AppPrimaryButton(
                  label: 'Coba lagi',
                  icon: Icons.refresh_rounded,
                  onPressed: _checkSession,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Ke halaman login',
                    style: AppText.body(14, color: AppColors.muted),
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
