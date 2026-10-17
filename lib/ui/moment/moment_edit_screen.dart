import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/model/moment_model.dart';
import '../../data/repository/moment_repository.dart';
import '../auth/auth_provider.dart';
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
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.of(context).pop();
                provider.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.of(context).pop();
                provider.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave(MomentProvider provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null || user.coupleId == null) return;

    if (provider.selectedImageBase64 == null && _existingMoment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih foto terlebih dahulu')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Moment berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menyimpan moment'),
          backgroundColor: Colors.redAccent,
        ),
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
            appBar: AppBar(
              title: const Text('Perbarui Moment Saya'),
              actions: [
                if (provider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _handleSave(provider),
                  ),
              ],
            ),
            body: _isLoadingExisting
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: () => _showImageSourceDialog(context, provider),
                          child: Container(
                            height: 280,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildImageWidget(provider),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => _showImageSourceDialog(context, provider),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Ganti Foto (Kamera / Galeri)'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Bagaimana perasaanmu saat ini? (Opsional)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 52,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _moodOptions.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final item = _moodOptions[index];
                              final emoji = item['emoji']!;
                              final isSelected = _selectedMood == emoji;

                              return ChoiceChip(
                                label: Text(
                                  '$emoji ${item['label']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected ? Colors.pink : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: Colors.pink.shade50,
                                side: BorderSide(
                                  color: isSelected ? Colors.pinkAccent : Colors.grey.shade300,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedMood = selected ? emoji : null;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _captionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Caption Moment',
                            hintText: 'Tuliskan perasaan atau momen hari ini...',
                            border: OutlineInputBorder(),
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

  Widget _buildImageWidget(MomentProvider provider) {
    if (provider.isCompressing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: 12),
            Text(
              'Mengompresi & menyiapkan foto...',
              style: TextStyle(color: Colors.grey, fontSize: 13),
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
        );
      } catch (_) {
        return const Center(child: Text('Gagal memuat foto'));
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey),
        SizedBox(height: 8),
        Text('Ketuk untuk menambah foto moment', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
