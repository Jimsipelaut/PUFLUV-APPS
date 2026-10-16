import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/model/important_date_model.dart';
import '../../data/model/moment_model.dart';
import '../../data/repository/couple_repository.dart';
import '../../data/repository/date_repository.dart';
import '../../data/repository/moment_repository.dart';
import '../../data/utils/widget_sync_manager.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../dates/date_list_screen.dart';
import '../moment/moment_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingCouple = true;

  @override
  void initState() {
    super.initState();
    _loadCoupleData();
  }

  Future<void> _loadCoupleData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null || user.coupleId == null) {
      setState(() => _isLoadingCouple = false);
      return;
    }

    try {
      final coupleRepo = CoupleRepository();
      await coupleRepo.getCouple(user.coupleId!);
      if (mounted) {
        setState(() {
          _isLoadingCouple = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCouple = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final coupleId = user?.coupleId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PUFLUV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Bagikan Kode Undangan',
            onPressed: () async {
              if (coupleId == null) return;
              final couple = await CoupleRepository().getCouple(coupleId);
              if (!context.mounted || couple == null) return;

              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Kode Undangan Pasangan'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Bagikan kode ini ke pasanganmu:'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.pinkAccent.shade100, width: 2),
                        ),
                        child: SelectableText(
                          couple.inviteCode,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Salin'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: couple.inviteCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kode disalin!')),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Bagikan'),
                            onPressed: () {
                              SharePlus.instance.share(
                                ShareParams(
                                  text: 'Yuk gabung di ruang privat kita di PUFLUV! Masukkan kode undangan: ${couple.inviteCode}',
                                  subject: 'Undangan PUFLUV Space',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.event_outlined),
            tooltip: 'Tanggal Penting',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DateListScreen()),
              );
            },
          ),
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
      body: _isLoadingCouple
          ? const Center(child: CircularProgressIndicator())
          : coupleId == null || coupleId.isEmpty
              ? const Center(child: Text('Belum terhubung dengan couple'))
              : StreamBuilder<List<MomentModel>>(
                  stream: MomentRepository().observeCoupleMoments(coupleId: coupleId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final moments = snapshot.data ?? [];
                    MomentModel? myMoment;
                    MomentModel? partnerMoment;

                    for (var m in moments) {
                      if (m.uid == user?.uid) {
                        myMoment = m;
                      } else {
                        partnerMoment = m;
                      }
                    }

                    // Sync otomatis ke Home Screen Widget native saat data moment berubah
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      WidgetSyncManager.syncWidget(partnerMoment: partnerMoment);
                    });

                    return ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        // Countdown Banner Terdekat
                        StreamBuilder<List<ImportantDateModel>>(
                          stream: DateRepository().observeDates(coupleId: coupleId),
                          builder: (context, dateSnapshot) {
                            final dates = dateSnapshot.data ?? [];
                            if (dates.isEmpty) return const SizedBox.shrink();

                            // Cari tanggal terdekat
                            dates.sort((a, b) => a.daysUntil(DateTime.now()).compareTo(b.daysUntil(DateTime.now())));
                            final nearest = dates.first;
                            final days = nearest.daysUntil(DateTime.now());

                            // Sync juga tanggal terdekat ke Widget native
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              WidgetSyncManager.syncWidget(
                                partnerMoment: partnerMoment,
                                dates: dates,
                              );
                            });

                            return Card(
                              color: Colors.pink.shade50,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.pinkAccent, size: 36),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nearest.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            days == 0 ? 'Hari ini!' : '$days hari lagi',
                                            style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => const DateListScreen()),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Momen Pasangan',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildMomentCard(
                          context,
                          title: 'Pasangan',
                          moment: partnerMoment,
                          isMe: false,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Momen Saya',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const MomentEditScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: Text(myMoment == null ? 'Tambah Moment' : 'Ganti Moment'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildMomentCard(
                          context,
                          title: 'Saya',
                          moment: myMoment,
                          isMe: true,
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _buildMomentCard(BuildContext context, {required String title, required MomentModel? moment, required bool isMe}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(isMe ? Icons.person : Icons.favorite, color: Colors.pinkAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 220,
                color: Colors.grey[200],
                child: moment != null && moment.photoBase64.isNotEmpty
                    ? Image.memory(
                        base64Decode(moment.photoBase64),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('Gagal memuat foto'),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              isMe ? 'Belum ada moment. Ketuk "Tambah Moment" di atas.' : 'Pasangan belum membagikan moment.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              moment?.caption.isNotEmpty == true ? moment!.caption : 'Tanpa caption',
              style: TextStyle(
                fontSize: 14,
                color: moment?.caption.isNotEmpty == true ? Colors.black87 : Colors.grey,
                fontStyle: moment?.caption.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
