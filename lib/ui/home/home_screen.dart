import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/model/moment_model.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../dates/date_list_screen.dart';
import '../moment/moment_edit_screen.dart';
import 'home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHomeProvider();
    });
  }

  void _initHomeProvider() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      Provider.of<HomeProvider>(context, listen: false).initialize(
        userId: user.uid,
        coupleId: user.coupleId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final user = authProvider.user;
    final couple = homeProvider.couple;
    final coupleId = user?.coupleId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PUFLUV'),
        actions: [
          if (couple != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Bagikan Kode Undangan',
              onPressed: () {
                _showInviteDialog(context, couple.inviteCode);
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
            onPressed: () => _confirmLogout(context, authProvider),
          ),
        ],
      ),
      body: homeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : coupleId == null || coupleId.isEmpty
              ? const Center(child: Text('Belum terhubung dengan couple'))
              : _buildHomeContent(context, homeProvider),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeProvider homeProvider) {
    final partnerMoment = homeProvider.partnerMoment;
    final myMoment = homeProvider.myMoment;
    final nearest = homeProvider.nearestDate;
    final couple = homeProvider.couple;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // State menunggu pasangan (M4)
        if (couple != null && !couple.isFull)
          Card(
            color: Colors.amber.shade50,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.hourglass_empty_rounded, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      Text(
                        'Menunggu Pasangan Bergabung',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bagikan kode undangan "${couple.inviteCode}" agar pasanganmu bisa bergabung.',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () => _showInviteDialog(context, couple.inviteCode),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Bagikan Kode'),
                  ),
                ],
              ),
            ),
          ),
        if (couple != null && !couple.isFull) const SizedBox(height: 16),

        // Countdown Banner Terdekat (H1 - daysUntil >= 0 saja)
        if (nearest != null) ...[
          Card(
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
                        Builder(builder: (_) {
                          final days = nearest.daysUntil(DateTime.now());
                          return Text(
                            days == 0 ? 'Hari ini!' : '$days hari lagi',
                            style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w600),
                          );
                        }),
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
          ),
          const SizedBox(height: 16),
        ],

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
          homeProvider: homeProvider,
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
          homeProvider: homeProvider,
        ),
      ],
    );
  }

  void _showInviteDialog(BuildContext context, String inviteCode) {
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
                inviteCode,
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
                    Clipboard.setData(ClipboardData(text: inviteCode));
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
                        text: 'Yuk gabung di ruang privat kita di PUFLUV! Masukkan kode undangan: $inviteCode',
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
  }

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentCard(
    BuildContext context, {
    required String title,
    required MomentModel? moment,
    required bool isMe,
    required HomeProvider homeProvider,
  }) {
    final cachedBytes = (moment != null) ? homeProvider.getCachedImage(moment) : null;

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
                child: cachedBytes != null
                    ? Image.memory(
                        cachedBytes,
                        fit: BoxFit.cover,
                        gaplessPlayback: true, // Mencegah flicker saat reload (H4)
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
