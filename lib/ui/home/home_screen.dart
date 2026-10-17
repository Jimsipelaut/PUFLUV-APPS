import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/model/important_date_model.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../dates/date_list_screen.dart';
import '../moment/moment_edit_screen.dart';
import 'home_provider.dart';
import 'reaction_tag_bottom_sheet.dart';

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
      _initHomeData();
    });
  }

  void _initHomeData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.initialize(
        userId: user.uid,
        coupleId: user.coupleId,
      );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E1014),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE6D3C3))),
      );
    }

    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1014),
      body: SafeArea(
        child: homeProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE6D3C3)))
            : RefreshIndicator(
                color: const Color(0xFFE6D3C3),
                backgroundColor: const Color(0xFF181B22),
                onRefresh: () async {
                  homeProvider.initialize(
                    userId: user.uid,
                    coupleId: user.coupleId,
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Bar: Brand Logo + Menu / Settings
                      _buildTopBar(context, authProvider, homeProvider),
                      const SizedBox(height: 18),

                      // Jika status couple belum full (Menunggu Pasangan)
                      if (homeProvider.couple != null && !homeProvider.couple!.isFull)
                        _buildWaitingCard(context, homeProvider.couple!.inviteCode),

                      // Card Partner Moment (Hero Card 370px)
                      _buildPartnerHeroCard(context, homeProvider),
                      const SizedBox(height: 18),

                      // Balasan Reaksi Cepat / Tag Balasan Bar
                      _buildReactionTagsBar(context, homeProvider),
                      const SizedBox(height: 18),

                      // Card Countdown Anniversary & Tanggal Penting
                      _buildCountdownCard(context, homeProvider),
                      const SizedBox(height: 18),

                      // Bar Mini: Momen Kamu Saat Ini
                      _buildMyMomentMiniBar(context, homeProvider),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    AuthProvider authProvider,
    HomeProvider homeProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'PUFLUV',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.0,
            color: const Color(0xFFE6D3C3),
          ),
        ),
        Row(
          children: [
            if (homeProvider.couple != null)
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Color(0xFFFAF6F1), size: 20),
                tooltip: 'Bagikan Kode Pasangan',
                onPressed: () => _showInviteDialog(context, homeProvider.couple!.inviteCode),
              ),
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFFFAF6F1), size: 24),
              onPressed: () => _showMenuBottomSheet(context, authProvider, homeProvider),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWaitingCard(BuildContext context, String inviteCode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6D3C3).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_border, color: Color(0xFFE6D3C3), size: 18),
              const SizedBox(width: 8),
              Text(
                'Menunggu Pasangan Bergabung',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFFFAF6F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Bagikan kode undangan ini ke pasanganmu agar ruang privat kalian langsung terhubung:',
            style: GoogleFonts.dmSans(color: const Color(0xFF9AA0AA), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1014),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  inviteCode,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: const Color(0xFFE6D3C3),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.share, size: 14),
                label: const Text('Bagikan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6D3C3),
                  foregroundColor: const Color(0xFF14161B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
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
    );
  }

  Widget _buildPartnerHeroCard(BuildContext context, HomeProvider homeProvider) {
    final partner = homeProvider.partnerMoment;
    final cachedBytes = partner != null ? homeProvider.getCachedImage(partner) : null;
    final partnerReaction = homeProvider.partnerReaction;

    return Container(
      height: 370,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const RadialGradient(
          center: Alignment(-0.4, -0.4),
          radius: 0.8,
          colors: [
            Color(0x8CA08A78),
            Color(0x00A08A78),
          ],
        ),
        color: const Color(0xFF252931),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gambar Foto Partner
          if (cachedBytes != null)
            Image.memory(
              cachedBytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(),
            )
          else
            _buildPlaceholderPhoto(),

          // Linear Gradient Overlay dari desain (to bottom rgba(0,0,0,0.2) -> rgba(0,0,0,0.8))
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35, 1.0],
                colors: [
                  Color(0x33000000),
                  Color(0x00000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),

          // Partner Reaction Badge (jika ada balasan terakhir dari pasangan)
          if (partnerReaction != null && partnerReaction.tag.isNotEmpty)
            Positioned(
              top: 18,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1014).withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE6D3C3).withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFFE6D3C3), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      partnerReaction.tag,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFAF6F1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Caption & Timestamp / Mood di bagian bawah
          Positioned(
            left: 24,
            right: 24,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  partner?.caption.isNotEmpty == true
                      ? partner!.caption
                      : (partner == null ? 'Belum ada moment dari pasangan' : 'Tanpa caption'),
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: const Color(0xFFFAF6F1),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      partner != null ? _formatTimeAgo(partner.updatedAt.toDate()) : 'Pasangan',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFFD4CCC3),
                      ),
                    ),
                    if (partner?.mood != null && partner!.mood!.isNotEmpty) ...[
                      Text(
                        ' · ',
                        style: GoogleFonts.dmSans(color: const Color(0xFFD4CCC3), fontSize: 13),
                      ),
                      Text(
                        partner.mood!,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5A626E),
            Color(0xFF3B414B),
            Color(0xFF252931),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 48, color: Color(0xFFD4CCC3)),
            const SizedBox(height: 10),
            Text(
              'Menunggu foto dari pasangan',
              style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFFD4CCC3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionTagsBar(BuildContext context, HomeProvider homeProvider) {
    final tags = homeProvider.reactionTags;
    final myReaction = homeProvider.myReaction;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...tags.map((tag) {
          final isSelected = myReaction?.tag == tag;
          return InkWell(
            onTap: () async {
              await homeProvider.sendReaction(tag);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reaksi "$tag" terkirim ke pasangan!'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: const Color(0xFF181B22),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: isSelected ? const Color(0xFFE6D3C3).withValues(alpha: 0.15) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFE6D3C3) : Colors.white.withValues(alpha: 0.14),
                ),
              ),
              child: Text(
                tag,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFFE6D3C3) : const Color(0xFFFAF6F1),
                ),
              ),
            ),
          );
        }),
        // Tombol '+' untuk membuka BottomSheet Tag Balasan
        InkWell(
          onTap: () {
            ReactionTagBottomSheet.show(
              context,
              currentTags: homeProvider.reactionTags,
              onSave: (newTags) async {
                await homeProvider.updateReactionTags(newTags);
              },
            );
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE6D3C3),
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              '+',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFFE6D3C3),
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownCard(BuildContext context, HomeProvider homeProvider) {
    final now = DateTime.now();
    final upcomingDates = homeProvider.dates.where((d) => d.daysUntil(now) >= 0).toList()
      ..sort((a, b) => a.daysUntil(now).compareTo(b.daysUntil(now)));

    final nearest = upcomingDates.isNotEmpty ? upcomingDates.first : null;
    final otherDates = upcomingDates.length > 1 ? upcomingDates.sublist(1, upcomingDates.length > 3 ? 3 : upcomingDates.length) : <ImportantDateModel>[];

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DateListScreen()),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF181B22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section: Nearest Event + Big Number
            if (nearest != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nearest.title.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.6,
                          color: const Color(0xFFE6D3C3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateString(nearest.date),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFF9AA0AA),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${nearest.daysUntil(now)}',
                        style: GoogleFonts.fraunces(
                          fontSize: 56,
                          height: 0.9,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFFFAF6F1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'hari lagi',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: const Color(0xFFD4CCC3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TANGGAL PENTING',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE6D3C3),
                    ),
                  ),
                  Text(
                    'Belum ada tanggal',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF9AA0AA),
                    ),
                  ),
                ],
              ),
            ],

            // Divider jika ada list agenda tambahan
            if (otherDates.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              const SizedBox(height: 12),
              ...otherDates.map((item) {
                final days = item.daysUntil(now);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFFFAF6F1),
                        ),
                      ),
                      Text(
                        '$days hari',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFF9AA0AA),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateString(String dateStr) {
    try {
      final parsed = DateFormat('yyyy-MM-dd').parseStrict(dateStr);
      return DateFormat('d MMMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildMyMomentMiniBar(BuildContext context, HomeProvider homeProvider) {
    final myMoment = homeProvider.myMoment;
    final cachedBytes = myMoment != null ? homeProvider.getCachedImage(myMoment) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
        children: [
          // Thumbnail Foto
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6B7380), Color(0xFF2F343D)],
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: cachedBytes != null
                ? Image.memory(
                    cachedBytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : const Icon(Icons.photo_camera_outlined, color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 14),

          // Caption & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  myMoment?.caption.isNotEmpty == true
                      ? myMoment!.caption
                      : 'Belum ada moment kamu',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFAF6F1),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  myMoment != null
                      ? 'Kamu · ${_formatTimeAgo(myMoment.updatedAt.toDate())}'
                      : 'Bagikan foto dan kabarmu hari ini',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF9AA0AA),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Tombol Ganti / Tambah
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MomentEditScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE6D3C3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: Text(
              myMoment != null ? 'Ganti' : 'Tambah',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE6D3C3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context, String inviteCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Kode Undangan Pasangan',
          style: GoogleFonts.dmSans(color: const Color(0xFFFAF6F1), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1014),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                inviteCode,
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: const Color(0xFFE6D3C3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy, size: 16, color: Color(0xFFFAF6F1)),
                  label: Text('Salin', style: GoogleFonts.dmSans(color: const Color(0xFFFAF6F1))),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kode disalin!')),
                    );
                  },
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.share, size: 16, color: Color(0xFF14161B)),
                  label: Text('Bagikan', style: GoogleFonts.dmSans(color: const Color(0xFF14161B))),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE6D3C3)),
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
            child: Text('Tutup', style: GoogleFonts.dmSans(color: const Color(0xFF9AA0AA))),
          ),
        ],
      ),
    );
  }

  void _showMenuBottomSheet(
    BuildContext context,
    AuthProvider authProvider,
    HomeProvider homeProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Color(0xFFE6D3C3)),
                title: Text('Daftar Tanggal Penting', style: GoogleFonts.dmSans(color: const Color(0xFFFAF6F1))),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DateListScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_offer_outlined, color: Color(0xFFE6D3C3)),
                title: Text('Atur Tag Balasan', style: GoogleFonts.dmSans(color: const Color(0xFFFAF6F1))),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ReactionTagBottomSheet.show(
                    context,
                    currentTags: homeProvider.reactionTags,
                    onSave: (tags) => homeProvider.updateReactionTags(tags),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: Text('Keluar dari Akun', style: GoogleFonts.dmSans(color: Colors.redAccent)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _confirmLogout(context, authProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Logout',
          style: GoogleFonts.dmSans(color: const Color(0xFFFAF6F1), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun ini?',
          style: GoogleFonts.dmSans(color: const Color(0xFF9AA0AA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Batal', style: GoogleFonts.dmSans(color: const Color(0xFF9AA0AA))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
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
}

