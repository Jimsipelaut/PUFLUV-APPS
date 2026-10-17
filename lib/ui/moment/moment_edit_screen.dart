import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/model/moment_model.dart';
import '../../data/repository/moment_repository.dart';
import '../auth/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import 'moment_provider.dart';

class MomentEditScreen extends StatefulWidget {
  const MomentEditScreen({super.key});

  @override
  State<MomentEditScreen> createState() => _MomentEditScreenState();
}

class _MomentEditScreenState extends State<MomentEditScreen> {
  final _captionController = TextEditingController();
  MomentModel? _existingMoment;
  bool _isLoadingExisting = true;
  String? _selectedMood;

  // 6 Pilihan Mood standar sesuai spesifikasi Audit Bagian 4
  final List<Map<String, String>> _moodOptions = const [
    {'emoji': '😊', 'label': 'Senang'},
    {'emoji': '🥰', 'label': 'Sayang'},
    {'emoji': '😴', 'label': 'Lelah'},
    {'emoji': '😤', 'label': 'Kesal'},
    {'emoji': '😢', 'label': 'Sedih'},
    {'emoji': '🤒', 'label': 'Kurang enak badan'},
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingMoment();
  }

  Future<void> _loadExistingMoment() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null || user.coupleId == null) {
      setState(() => _isLoadingExisting = false);
      return;
    }

    try {
      final repo = MomentRepository();
      final moment = await repo.getMoment(
        coupleId: user.coupleId!,
        uid: user.uid,
      );
      if (moment != null && mounted) {
        setState(() {
          _existingMoment = moment;
          _captionController.text = moment.caption;
          _selectedMood = moment.mood;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingExisting = false);
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog(BuildContext context, MomentProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Foto moment', style: AppText.body(18, weight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                'Foto lama akan otomatis tertimpa.',
                style: AppText.body(13, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              _SourceTile(
                icon: Icons.camera_alt_outlined,
                label: 'Ambil dari kamera',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.pickImage(ImageSource.camera);
                },
              ),
              _SourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Pilih dari galeri',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(MomentProvider provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null || user.coupleId == null) return;

    if (provider.selectedImageBase64 == null && _existingMoment == null) {
      AppSnack.show(
        context,
        'Silakan pilih foto terlebih dahulu',
        type: AppSnackType.error,
      );
      return;
    }

    final success = await provider.saveMoment(
      coupleId: user.coupleId!,
      uid: user.uid,
      caption: _captionController.text.trim(),
      existingPhotoBase64: _existingMoment?.photoBase64,
      mood: _selectedMood,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      AppSnack.show(
        context,
        'Moment berhasil diperbarui!',
        type: AppSnackType.success,
      );
    } else {
      AppSnack.show(
        context,
        provider.errorMessage ?? 'Gagal menyimpan moment',
        type: AppSnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MomentProvider(),
      child: Consumer<MomentProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            appBar: AppBar(
              title: const Text('Perbarui moment'),
            ),
            body: _isLoadingExisting
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildPhotoArea(context, provider),
                                const SizedBox(height: 24),
                                Text(
                                  'Bagaimana perasaanmu saat ini? (opsional)',
                                  style: AppText.fieldLabel(),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _moodOptions.map((item) {
                                    final emoji = item['emoji']!;
                                    return _MoodPill(
                                      emoji: emoji,
                                      label: item['label']!,
                                      selected: _selectedMood == emoji,
                                      onTap: () {
                                        setState(() {
                                          _selectedMood =
                                              _selectedMood == emoji ? null : emoji;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24),
                                AppTextField(
                                  controller: _captionController,
                                  label: 'Caption',
                                  hint: 'lagi makan nih hehe',
                                  maxLines: 3,
                                  textCapitalization: TextCapitalization.sentences,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: AppPrimaryButton(
                            label: 'Simpan moment',
                            loading: provider.isLoading,
                            onPressed: provider.isCompressing
                                ? null
                                : () => _handleSave(provider),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  /// Area foto: kartu 28px berlatar gradien abu-biru, sama dengan hero Home.
  Widget _buildPhotoArea(BuildContext context, MomentProvider provider) {
    final hasPhoto = provider.selectedImageFile != null ||
        (_existingMoment != null && _existingMoment!.photoBase64.isNotEmpty);

    return GestureDetector(
      onTap: () => _showImageSourceDialog(context, provider),
      child: Container(
        height: 340,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFF5A626E),
              Color(0xFF3B414B),
              Color(0xFF252931),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageWidget(provider),
            if (hasPhoto && !provider.isCompressing)
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.6, 1.0],
                      colors: [
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0x99000000),
                      ],
                    ),
                  ),
                ),
              ),
            if (!provider.isCompressing)
              Positioned(
                right: 16,
                bottom: 16,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bg.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasPhoto ? 'Ganti foto' : 'Tambah foto',
                        style: AppText.body(13, weight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(MomentProvider provider) {
    if (provider.isCompressing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 14),
            Text(
              'Mengompresi & menyiapkan foto...',
              style: AppText.body(13, color: AppColors.textSoft),
            ),
          ],
        ),
      );
    }

    if (provider.selectedImageFile != null) {
      return Image.file(
        provider.selectedImageFile!,
        fit: BoxFit.cover,
      );
    }

    if (_existingMoment != null && _existingMoment!.photoBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(_existingMoment!.photoBase64);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      } catch (_) {
        return Center(
          child: Text(
            'Gagal memuat foto',
            style: AppText.body(13, color: AppColors.textSoft),
          ),
        );
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.textSoft),
          const SizedBox(height: 12),
          Text(
            'Ketuk untuk menambah foto moment',
            style: AppText.body(14, color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}

/// Pill mood: sama dengan gaya tag balasan di Home (44px, radius 22).
class _MoodPill extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MoodPill({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: selected
              ? AppColors.accent.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppText.body(
                14,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.accent : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outline),
              ),
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label, style: AppText.body(15)),
          ],
        ),
      ),
    );
  }
}
