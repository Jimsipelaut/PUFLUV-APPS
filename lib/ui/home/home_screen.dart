import 'dart:async';
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

// ---------- Warna Konstanta ----------
const _bg = Color(0xFF0E1014);
const _surface = Color(0xFF181B22);
const _elevated = Color(0xFF252931);
const _accent = Color(0xFFE6D3C3);
const _textPrimary = Color(0xFFFAF6F1);
const _textMuted = Color(0xFF9AA0AA);
const _textSub = Color(0xFFD4CCC3);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  late AnimationController _reactionRippleCtrl;
  String? _lastReactedTag;

  @override
  void initState() {
    super.initState();
    _reactionRippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initHomeData());
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _reactionRippleCtrl.dispose();
    super.dispose();
  }

  void _initHomeData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user != null) {
      Provider.of<HomeProvider>(context, listen: false).initialize(
        userId: user.uid,
        coupleId: user.coupleId,
      );
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = _now.difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  String _formatDate(String dateStr) {
    try {
      final p = DateFormat('yyyy-MM-dd').parseStrict(dateStr);
      return DateFormat('d MMMM yyyy', 'id_ID').format(p);
    } catch (_) {
      return dateStr;
    }
  }

  String _liveCountdown(DateTime targetDate) {
    final end = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);
    final diff = end.difference(_now);
    if (diff.isNegative) return '00:00:00';
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    final hp = Provider.of<HomeProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: _bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: hp.isLoading
              ? const Center(child: CircularProgressIndicator(color: _accent))
              : RefreshIndicator(
                  color: _accent,
                  backgroundColor: _surface,
                  onRefresh: () async => hp.initialize(
                    userId: user.uid,
                    coupleId: user.coupleId,
                  ),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // TOP BAR
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
                          child: _TopBar(
                            hp: hp,
                            onMenu: () => _showMenu(context, auth, hp),
                            onInvite: () => _showInvite(context, hp.couple?.inviteCode ?? ''),
                          ),
                        ),
                      ),

                      // WAITING CARD
                      if (hp.couple != null && !hp.couple!.isFull)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: _WaitingCard(inviteCode: hp.couple!.inviteCode),
                          ),
                        ),

                      // HERO CARD PARTNER
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _HeroCard(
                            hp: hp,
                            now: _now,
                            formatTimeAgo: _formatTimeAgo,
                            onQuickReact: _sendReaction,
                            lastReactedTag: _lastReactedTag,
                            rippleCtrl: _reactionRippleCtrl,
                          ),
                        ),
                      ),

                      // REACTION TAGS
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _ReactionBar(
                            hp: hp,
                            lastReactedTag: _lastReactedTag,
                            onReact: _sendReaction,
                            onEditTags: () => ReactionTagBottomSheet.show(
                              context,
                              currentTags: hp.reactionTags,
                              onSave: (t) async => hp.updateReactionTags(t),
                            ),
                          ),
                        ),
                      ),

                      // COUNTDOWN CARD
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          child: _CountdownCard(
                            hp: hp,
                            now: _now,
                            formatDate: _formatDate,
                            liveCountdown: _liveCountdown,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const DateListScreen()),
                            ),
                          ),
                        ),
                      ),

                      // MY MOMENT CARD
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                          child: _MyMomentCard(
                            hp: hp,
                            formatTimeAgo: _formatTimeAgo,
                            onEdit: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const MomentEditScreen()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _sendReaction(String tag) async {
    final hp = Provider.of<HomeProvider>(context, listen: false);
    setState(() => _lastReactedTag = tag);
    _reactionRippleCtrl.forward(from: 0);
    await hp.sendReaction(tag);
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('Reaksi "$tag" terkirim ke pasangan 💌'),
          duration: const Duration(seconds: 1),
          backgroundColor: _surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ));
    }
  }

  void _showInvite(BuildContext ctx, String code) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _InviteSheet(inviteCode: code),
    );
  }

  void _showMenu(BuildContext ctx, AuthProvider auth, HomeProvider hp) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: _textMuted.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              _MenuTile(icon: Icons.calendar_month, label: 'Daftar Tanggal Penting', onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const DateListScreen()));
              }),
              _MenuTile(icon: Icons.local_offer_outlined, label: 'Atur Tag Balasan', onTap: () {
                Navigator.pop(sheetCtx);
                ReactionTagBottomSheet.show(ctx, currentTags: hp.reactionTags, onSave: (t) => hp.updateReactionTags(t));
              }),
              if (hp.couple != null)
                _MenuTile(icon: Icons.share_outlined, label: 'Bagikan Kode Pasangan', onTap: () {
                  Navigator.pop(sheetCtx);
                  _showInvite(ctx, hp.couple!.inviteCode);
                }),
              const Divider(height: 24, color: Color(0xFF252931)),
              _MenuTile(icon: Icons.logout, label: 'Keluar dari Akun', destructive: true, onTap: () {
                Navigator.pop(sheetCtx);
                _confirmLogout(ctx, auth);
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext ctx, AuthProvider auth) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar?', style: GoogleFonts.fraunces(color: _textPrimary, fontSize: 22)),
        content: Text('Semua data tetap aman. Kamu bisa masuk kembali kapan saja.', style: GoogleFonts.dmSans(color: _textMuted, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text('Batal', style: GoogleFonts.dmSans(color: _textMuted))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await auth.logout();
              if (ctx.mounted) {
                Navigator.of(ctx).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: Text('Keluar', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════
class _TopBar extends StatelessWidget {
  final HomeProvider hp;
  final VoidCallback onMenu;
  final VoidCallback onInvite;
  const _TopBar({required this.hp, required this.onMenu, required this.onInvite});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'PUFLUV',
          style: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: _accent,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.menu_rounded, color: _textPrimary, size: 24),
          onPressed: onMenu,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════
// WAITING CARD
// ═══════════════════════════════════════
class _WaitingCard extends StatelessWidget {
  final String inviteCode;
  const _WaitingCard({required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.favorite_border, color: _accent, size: 16),
            const SizedBox(width: 8),
            Text('Menunggu Pasangan Bergabung',
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary)),
          ]),
          const SizedBox(height: 8),
          Text('Bagikan kode ini ke pasanganmu:',
              style: GoogleFonts.dmSans(fontSize: 12, color: _textMuted)),
          const SizedBox(height: 12),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
              child: Text(inviteCode,
                  style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3, color: _accent)),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.share_rounded, size: 14, color: _bg),
              label: Text('Bagikan', style: GoogleFonts.dmSans(fontSize: 13, color: _bg, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () => SharePlus.instance.share(ShareParams(
                text: 'Yuk gabung di ruang privat kita di PUFLUV! Kode: $inviteCode',
                subject: 'Undangan PUFLUV Space',
              )),
            ),
          ]),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// HERO CARD PARTNER
// ═══════════════════════════════════════
class _HeroCard extends StatelessWidget {
  final HomeProvider hp;
  final DateTime now;
  final String Function(DateTime) formatTimeAgo;
  final Future<void> Function(String) onQuickReact;
  final String? lastReactedTag;
  final AnimationController rippleCtrl;

  const _HeroCard({
    required this.hp,
    required this.now,
    required this.formatTimeAgo,
    required this.onQuickReact,
    required this.lastReactedTag,
    required this.rippleCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final partner = hp.partnerMoment;
    final cachedBytes = partner != null ? hp.getCachedImage(partner) : null;
    final partnerReaction = hp.partnerReaction;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: _elevated,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // FOTO
            cachedBytes != null
                ? Image.memory(cachedBytes, fit: BoxFit.cover, gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => _Placeholder())
                : _Placeholder(),

            // GRADIENT SCRIM
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.38, 1.0],
                  colors: [Color(0x55000000), Color(0x00000000), Color(0xDD000000)],
                ),
              ),
            ),

            // PARTNER REACTION BADGE
            if (partnerReaction != null && partnerReaction.tag.isNotEmpty)
              Positioned(
                top: 16,
                left: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _bg.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _accent.withValues(alpha: 0.45)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.favorite_rounded, color: _accent, size: 13),
                    const SizedBox(width: 6),
                    Text(partnerReaction.tag,
                        style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: _textPrimary)),
                  ]),
                ),
              ),

            // QUICK REACT BUTTON
            Positioned(
              top: 14,
              right: 16,
              child: _QuickReactButton(
                tags: hp.reactionTags,
                myReaction: hp.myReaction?.tag,
                onReact: onQuickReact,
              ),
            ),

            // CAPTION + MOOD + WAKTU
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (partner?.mood != null && partner!.mood!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(partner.mood!, style: const TextStyle(fontSize: 22)),
                    ),
                  Text(
                    partner?.caption.isNotEmpty == true
                        ? partner!.caption
                        : (partner == null ? 'Belum ada moment dari pasangan' : 'Tanpa caption'),
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: _textPrimary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    partner != null ? formatTimeAgo(partner.updatedAt.toDate()) : 'Pasangan',
                    style: GoogleFonts.dmSans(fontSize: 12, color: _textSub),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B414B), Color(0xFF1E2228)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border_rounded, size: 44, color: Color(0xFF5A626E)),
          const SizedBox(height: 10),
          Text('Menunggu foto dari pasangan',
              style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF5A626E))),
        ],
      ),
    );
  }
}

class _QuickReactButton extends StatefulWidget {
  final List<String> tags;
  final String? myReaction;
  final Future<void> Function(String) onReact;
  const _QuickReactButton({required this.tags, required this.myReaction, required this.onReact});

  @override
  State<_QuickReactButton> createState() => _QuickReactButtonState();
}

class _QuickReactButtonState extends State<_QuickReactButton> with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final hasReaction = widget.myReaction != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _scale,
          alignment: Alignment.topRight,
          child: _open
              ? Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _bg.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _accent.withValues(alpha: 0.3)),
                  ),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.tags.map((tag) {
                      final sel = widget.myReaction == tag;
                      return GestureDetector(
                        onTap: () async {
                          _toggle();
                          await widget.onReact(tag);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? _accent.withValues(alpha: 0.2) : _elevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: sel ? _accent : Colors.transparent),
                          ),
                          child: Text(tag,
                              style: GoogleFonts.dmSans(fontSize: 12, color: sel ? _accent : _textPrimary)),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: hasReaction ? _accent.withValues(alpha: 0.2) : _bg.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: hasReaction ? _accent : _accent.withValues(alpha: 0.4),
                width: hasReaction ? 1.5 : 1,
              ),
            ),
            child: Icon(
              hasReaction ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _accent,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════
// REACTION BAR
// ═══════════════════════════════════════
class _ReactionBar extends StatelessWidget {
  final HomeProvider hp;
  final String? lastReactedTag;
  final Future<void> Function(String) onReact;
  final VoidCallback onEditTags;

  const _ReactionBar({
    required this.hp,
    required this.lastReactedTag,
    required this.onReact,
    required this.onEditTags,
  });

  @override
  Widget build(BuildContext context) {
    final tags = hp.reactionTags;
    final myReaction = hp.myReaction?.tag;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...tags.map((tag) {
            final selected = myReaction == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ReactionChip(
                tag: tag,
                selected: selected,
                onTap: () => onReact(tag),
              ),
            );
          }),
          GestureDetector(
            onTap: onEditTags,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _accent.withValues(alpha: 0.6)),
              ),
              child: const Icon(Icons.add, color: _accent, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatefulWidget {
  final String tag;
  final bool selected;
  final VoidCallback onTap;
  const _ReactionChip({required this.tag, required this.selected, required this.onTap});

  @override
  State<_ReactionChip> createState() => _ReactionChipState();
}

class _ReactionChipState extends State<_ReactionChip> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: () {
          _ctrl.forward(from: 0);
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: widget.selected ? _accent.withValues(alpha: 0.15) : Colors.transparent,
            border: Border.all(
              color: widget.selected ? _accent : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            widget.tag,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: widget.selected ? FontWeight.w600 : FontWeight.normal,
              color: widget.selected ? _accent : _textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// COUNTDOWN CARD
// ═══════════════════════════════════════
class _CountdownCard extends StatelessWidget {
  final HomeProvider hp;
  final DateTime now;
  final String Function(String) formatDate;
  final String Function(DateTime) liveCountdown;
  final VoidCallback onTap;

  const _CountdownCard({
    required this.hp,
    required this.now,
    required this.formatDate,
    required this.liveCountdown,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = hp.dates.where((d) => d.daysUntil(now) >= 0).toList()
      ..sort((a, b) => a.daysUntil(now).compareTo(b.daysUntil(now)));
    final nearest = upcoming.isNotEmpty ? upcoming.first : null;
    final others = upcoming.length > 1 ? upcoming.sublist(1, upcoming.length > 4 ? 4 : upcoming.length) : <ImportantDateModel>[];
    final nearestDays = nearest != null ? nearest.daysUntil(now) : -1;
    final isToday = nearestDays == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (nearest != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nearest.title.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.8,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatDate(nearest.date),
                          style: GoogleFonts.dmSans(fontSize: 12, color: _textMuted),
                        ),
                        if (isToday) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('🎉 Hari ini!',
                                style: GoogleFonts.dmSans(fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isToday)
                        Text(
                          liveCountdown(_parseDate(nearest.date)),
                          style: GoogleFonts.fraunces(
                            fontSize: 28,
                            height: 1,
                            fontWeight: FontWeight.w400,
                            color: _accent,
                          ),
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$nearestDays',
                              style: GoogleFonts.fraunces(
                                fontSize: 56,
                                height: 0.9,
                                fontWeight: FontWeight.w400,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('hari lagi',
                                style: GoogleFonts.dmSans(fontSize: 13, color: _textSub)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TANGGAL PENTING',
                      style: GoogleFonts.dmSans(fontSize: 10, letterSpacing: 2.4, fontWeight: FontWeight.w700, color: _accent)),
                  Text('Belum ada', style: GoogleFonts.dmSans(fontSize: 13, color: _textMuted)),
                ],
              ),
            ],

            if (others.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.07)),
              const SizedBox(height: 10),
              ...others.map((item) {
                final d = item.daysUntil(now);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 5, height: 5, decoration: BoxDecoration(color: _textMuted.withValues(alpha: 0.5), shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item.title, style: GoogleFonts.dmSans(fontSize: 13, color: _textPrimary))),
                      Text(d == 0 ? 'Hari ini' : '$d hari',
                          style: GoogleFonts.dmSans(fontSize: 12, color: _textMuted)),
                    ],
                  ),
                );
              }),
            ],

            if (nearest == null) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: _accent.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add, color: _accent, size: 16),
                    const SizedBox(width: 6),
                    Text('Tambah tanggal penting',
                        style: GoogleFonts.dmSans(fontSize: 13, color: _accent, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  DateTime _parseDate(String s) {
    try {
      return DateFormat('yyyy-MM-dd').parseStrict(s);
    } catch (_) {
      return DateTime.now();
    }
  }
}

// ═══════════════════════════════════════
// MY MOMENT CARD
// ═══════════════════════════════════════
class _MyMomentCard extends StatelessWidget {
  final HomeProvider hp;
  final String Function(DateTime) formatTimeAgo;
  final VoidCallback onEdit;

  const _MyMomentCard({required this.hp, required this.formatTimeAgo, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final my = hp.myMoment;
    final cachedBytes = my != null ? hp.getCachedImage(my) : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 68,
              height: 68,
              color: _elevated,
              child: cachedBytes != null
                  ? Image.memory(cachedBytes, fit: BoxFit.cover, gaplessPlayback: true)
                  : const Icon(Icons.photo_camera_outlined, color: Color(0xFF5A626E), size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moment Kamu',
                  style: GoogleFonts.dmSans(fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w600, color: _accent),
                ),
                const SizedBox(height: 4),
                Text(
                  my?.caption.isNotEmpty == true ? my!.caption : 'Belum ada moment hari ini',
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: _textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (my != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    formatTimeAgo(my.updatedAt.toDate()),
                    style: GoogleFonts.dmSans(fontSize: 11, color: _textMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: my != null ? _elevated : _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withValues(alpha: 0.6)),
              ),
              child: Text(
                my != null ? 'Ganti' : 'Tambah',
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: _accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// INVITE BOTTOM SHEET
// ═══════════════════════════════════════
class _InviteSheet extends StatelessWidget {
  final String inviteCode;
  const _InviteSheet({required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _textMuted.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Kode Undangan', style: GoogleFonts.fraunces(fontSize: 22, color: _textPrimary)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(18)),
              child: Text(
                inviteCode,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 5, color: _accent),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 16, color: _textPrimary),
                  label: Text('Salin', style: GoogleFonts.dmSans(color: _textPrimary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3B414B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteCode));
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(const SnackBar(content: Text('Kode disalin!'), duration: Duration(seconds: 1)));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.share_rounded, size: 16, color: _bg),
                  label: Text('Bagikan', style: GoogleFonts.dmSans(color: _bg, fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => SharePlus.instance.share(ShareParams(
                    text: 'Yuk gabung di ruang privat kita di PUFLUV! Kode: $inviteCode',
                    subject: 'Undangan PUFLUV Space',
                  )),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// MENU TILE
// ═══════════════════════════════════════
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  const _MenuTile({required this.icon, required this.label, required this.onTap, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Colors.redAccent : _textPrimary;
    return ListTile(
      leading: Icon(icon, color: destructive ? Colors.redAccent : _accent, size: 22),
      title: Text(label, style: GoogleFonts.dmSans(color: color, fontSize: 15)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
