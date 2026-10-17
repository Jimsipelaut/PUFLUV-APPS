import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../couple/couple_setup_screen.dart';
import '../home/home_screen.dart';

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
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.pinkAccent,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gagal memuat profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Koneksi internet lambat atau terputus saat memeriksa sesi login.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _checkSession,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Ke Halaman Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              color: Colors.pinkAccent,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'PUFLUV',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
