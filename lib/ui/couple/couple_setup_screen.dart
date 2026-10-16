import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import 'couple_provider.dart';
import 'join_couple_screen.dart';

class CoupleSetupScreen extends StatelessWidget {
  const CoupleSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoupleProvider(),
      child: const _CoupleSetupView(),
    );
  }
}

class _CoupleSetupView extends StatelessWidget {
  const _CoupleSetupView();

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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      if (coupleProvider.couple != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kode undangan: ${coupleProvider.couple!.inviteCode}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(coupleProvider.errorMessage ?? 'Gagal membuat couple space'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final coupleProvider = Provider.of<CoupleProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hubungkan Pasangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Colors.pinkAccent,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Halo, ${user?.name ?? 'User'}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih salah satu cara untuk memulai ruang privat bersama pasanganmu:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 36),
                FilledButton.icon(
                  onPressed: coupleProvider.isLoading
                      ? null
                      : () => _handleCreateCouple(context),
                  icon: const Icon(Icons.add_circle_outline),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: coupleProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Buat Ruang Baru (Dapatkan Kode)',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: coupleProvider.isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const JoinCoupleScreen(),
                            ),
                          );
                        },
                  icon: const Icon(Icons.group_add_outlined),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: const Text(
                    'Gabung dengan Kode Undangan',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: coupleProvider.isLoading
                      ? null
                      : () async {
                          await authProvider.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                  child: const Text('Keluar (Logout)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
