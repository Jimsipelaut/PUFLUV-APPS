import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/model/important_date_model.dart';
import '../../data/repository/date_repository.dart';
import '../auth/auth_provider.dart';
import 'date_form_screen.dart';

class DateListScreen extends StatelessWidget {
  const DateListScreen({super.key});

  String _countdownText(ImportantDateModel date) {
    final days = date.daysUntil(DateTime.now());
    if (days == 0) return 'Hari ini';
    if (days == 1) return 'Besok';
    if (days > 0) return '$days hari lagi';
    return 'Terlewat ${days.abs()} hari';
  }

  Color _countdownColor(int days) {
    if (days == 0) return Colors.pinkAccent;
    if (days == 1) return Colors.orange;
    if (days > 0 && days <= 7) return Colors.green;
    if (days < 0) return Colors.grey;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final coupleId = user?.coupleId;

    if (coupleId == null || coupleId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tanggal Penting')),
        body: const Center(child: Text('Belum terhubung dengan couple')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanggal Penting'),
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
            return Center(child: Text('Gagal memuat: ${snapshot.error}'));
          }

          final dates = snapshot.data ?? [];

          if (dates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada tanggal penting',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tambahkan anniversary, ulang tahun, atau momen spesial kalian',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
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
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final d = sorted[index];
              final days = d.daysUntil(DateTime.now());
              DateTime parsedDate;
              try {
                parsedDate = DateFormat('yyyy-MM-dd').parseStrict(d.date);
              } catch (_) {
                parsedDate = DateTime.now();
              }
              String formatted;
              try {
                formatted = DateFormat('dd MMM yyyy', 'id_ID').format(parsedDate);
              } catch (_) {
                formatted = DateFormat('dd MMM yyyy').format(parsedDate);
              }

              return Dismissible(
                key: Key(d.dateId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Hapus',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus tanggal?'),
                      content: Text('Hapus "${d.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  try {
                    await DateRepository().deleteDate(coupleId: coupleId, dateId: d.dateId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('"${d.title}" berhasil dihapus')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menghapus: $e')),
                      );
                    }
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      d.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('$formatted${d.recurring ? ' • Tahunan' : ''}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _countdownColor(days).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _countdownColor(days).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _countdownText(d),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _countdownColor(days),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DateFormScreen(existing: d)),
                      );
                    },
                    onLongPress: () => _confirmDelete(context, coupleId, d),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String coupleId, ImportantDateModel date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus tanggal?'),
        content: Text('Hapus "${date.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await DateRepository().deleteDate(coupleId: coupleId, dateId: date.dateId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tanggal dihapus')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal hapus: $e')),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
