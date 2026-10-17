import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../home/home_screen.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import 'couple_provider.dart';

class JoinCoupleScreen extends StatefulWidget {
  const JoinCoupleScreen({super.key});

  @override
  State<JoinCoupleScreen> createState() => _JoinCoupleScreenState();
}

class _JoinCoupleScreenState extends State<JoinCoupleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coupleProvider = Provider.of<CoupleProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) return;

    final success = await coupleProvider.joinCouple(
      user,
      _codeController.text,
    );

    if (!mounted) return;

    if (success) {
      await authProvider.checkAuthSession();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );

      AppSnack.show(
        context,
        'Berhasil terhubung dengan pasangan!',
        type: AppSnackType.success,
      );
    } else {
      AppSnack.show(
        context,
        coupleProvider.errorMessage ?? 'Gagal bergabung dengan couple',
        type: AppSnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupleProvider = Provider.of<CoupleProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppScreenHeading(
                    title: 'Masukkan kode',
                    subtitle: 'Minta kode undangan dari pasanganmu yang sudah membuat ruang privat.',
                  ),
                  const SizedBox(height: 36),
                  AppTextField(
                    controller: _codeController,
                    label: 'Kode undangan',
                    hint: 'C0UP13',
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    style: AppText.body(
                      28,
                      weight: FontWeight.bold,
                      letterSpacing: 6,
                      color: AppColors.accent,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Kode undangan wajib diisi';
                      }
                      if (val.trim().length < 4) {
                        return 'Kode undangan tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  AppPrimaryButton(
                    label: 'Gabung sekarang',
                    loading: coupleProvider.isLoading,
                    onPressed: _handleJoin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
