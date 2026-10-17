import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/model/important_date_model.dart';
import '../../data/repository/date_repository.dart';
import '../auth/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import 'date_form_screen.dart';

class DateListScreen extends StatelessWidget {
  const DateListScreen({super.key});

  /// Angka hitung mundur di sisi kanan kartu (Fraunces, seperti kartu Home).
  Widget _buildCountdown(int days, {required bool featured}) {
    if (days > 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$days',
            style: AppText.display(featured ? 60 : 32, height: 0.9),
          ),
          SizedBox(width: featured ? 8 : 6),
          Text(
            'hari lagi',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: featured ? 14 : 12,
              color: AppColors.textSoft,
            ),
          ),
        ],
      );
    }
    if (days == 0 || days == 1) {
      return Text(
        days == 0 ? 'Hari ini' : 'Besok',
        style: AppText.display(featured ? 38 : 26, color: AppColors.accent, height: 1),
      );
    }
    return Text(
      'Terlewat ${days.abs()} hari',
      style: AppText.body(12, color: AppColors.muted),
    );
  }

  Widget _buildCard(
    ImportantDateModel d,
    int days,
    String formatted, {
    required bool featured,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    final past = days < 0;
    final dateLine = '$formatted${d.recurring ? ' · Tahunan' : ''}';

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (featured) ...[
          Text(
            d.title.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.label(),
          ),
          const SizedBox(height: 4),
        ] else ...[
          Text(
            d.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(
              15,
              weight: FontWeight.w500,
              color: past ? AppColors.muted : AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(dateLine, style: AppText.body(13, color: AppColors.muted)),
      ],
    );

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: featured
              ? AppColors.accent.withValues(alpha: 0.25)
              : AppColors.cardBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.all(featured ? 20 : 18),
          child: Row(
            crossAxisAlignment:
                featured ? CrossAxisAlignment.end : CrossAxisAlignment.center,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 12),
              _buildCountdown(days, featured: featured),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIconBadge(icon: Icons.event_note_outlined),
            const SizedBox(height: 24),
            Text(
              'Belum ada tanggal penting',
              style: AppText.body(18, weight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan anniversary, ulang tahun, atau momen spesial kalian.',
              textAlign: TextAlign.center,
              style: AppText.body(14, color: AppColors.muted, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final coupleId = user?.coupleId;

    if (coupleId == null || coupleId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('Tanggal penting')),
        body: Center(
          child: Text(
            'Belum terhubung dengan couple',
            style: AppText.body(14, color: AppColors.muted),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Tanggal penting'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DateFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: StreamBuilder<List<ImportantDateModel>>(
        stream: DateRepository().observeDates(coupleId: coupleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: AppText.body(14, color: AppColors.muted),
                ),
              ),
            );
          }

          final dates = snapshot.data ?? [];

          if (dates.isEmpty) {
            return _buildEmptyState();
          }

          // Urutkan: tanggal mendatang (daysUntil >= 0) terurut lebih dulu (terdekat di atas),
          // lalu tanggal lampau (daysUntil < 0) ditaruh di bagian bawah.
          final now = DateTime.now();
          final sorted = List<ImportantDateModel>.from(dates);
          sorted.sort((a, b) {
            final daysA = a.daysUntil(now);
            final daysB = b.daysUntil(now);
            if (daysA >= 0 && daysB >= 0) {
              return daysA.compareTo(daysB);
            } else if (daysA >= 0 && daysB < 0) {
              return -1; // Mendatang lebih awal
            } else if (daysA < 0 && daysB >= 0) {
              return 1; // Lampau di bawah
            } else {
              return daysB.compareTo(daysA); // Lampau: yang paling baru lewat di atas
            }
          });

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final d = sorted[index];
              final days = d.daysUntil(DateTime.now());
              // Tanggal terdekat tampil besar seperti kartu countdown di Home.
              final featured = index == 0 && days >= 0;
              DateTime parsedDate;
              try {
                parsedDate = DateFormat('yyyy-MM-dd').parseStrict(d.date);
              } catch (_) {
                parsedDate = DateTime.now();
              }
              String formatted;
              try {
                formatted = DateFormat('dd MMMM yyyy', 'id_ID').format(parsedDate);
              } catch (_) {
                formatted = DateFormat('dd MMMM yyyy').format(parsedDate);
              }

              return Dismissible(
                key: Key(d.dateId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.delete_outline, color: AppColors.danger, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Hapus',
                        style: AppText.body(
                          14,
                          weight: FontWeight.w500,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => _buildDeleteDialog(
                      d.title,
                      onConfirm: () => Navigator.of(ctx).pop(true),
                      onCancel: () => Navigator.of(ctx).pop(false),
                    ),
                  );
                },
                onDismissed: (_) async {
                  try {
                    await DateRepository().deleteDate(coupleId: coupleId, dateId: d.dateId);
                    if (context.mounted) {
                      AppSnack.show(context, '"${d.title}" berhasil dihapus');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      AppSnack.show(
                        context,
                        'Gagal menghapus: $e',
                        type: AppSnackType.error,
                      );
                    }
                  }
                },
                child: _buildCard(
                  d,
                  days,
                  formatted,
                  featured: featured,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DateFormScreen(existing: d)),
                    );
                  },
                  onLongPress: () => _confirmDelete(context, coupleId, d),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDeleteDialog(
    String title, {
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return AlertDialog(
      title: const Text('Hapus tanggal?'),
      content: Text('Hapus "$title"?'),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Batal', style: AppText.body(14, color: AppColors.muted)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: onConfirm,
          child: const Text('Hapus'),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String coupleId, ImportantDateModel date) {
    showDialog(
      context: context,
      builder: (ctx) => _buildDeleteDialog(
        date.title,
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () async {
          Navigator.of(ctx).pop();
          try {
            await DateRepository().deleteDate(coupleId: coupleId, dateId: date.dateId);
            if (context.mounted) {
              AppSnack.show(context, 'Tanggal dihapus');
            }
          } catch (e) {
            if (context.mounted) {
              AppSnack.show(context, 'Gagal hapus: $e', type: AppSnackType.error);
            }
          }
        },
      ),
    );
  }
}
