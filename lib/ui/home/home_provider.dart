import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/model/couple_model.dart';
import '../../data/model/important_date_model.dart';
import '../../data/model/moment_model.dart';
import '../../data/model/reaction_model.dart';
import '../../data/repository/couple_repository.dart';
import '../../data/repository/date_repository.dart';
import '../../data/repository/moment_repository.dart';
import '../../data/repository/reaction_repository.dart';
import '../../data/utils/widget_sync_manager.dart';

class HomeProvider with ChangeNotifier {
  final CoupleRepository _coupleRepository;
  final MomentRepository _momentRepository;
  final DateRepository _dateRepository;
  final ReactionRepository _reactionRepository;

  HomeProvider({
    CoupleRepository? coupleRepository,
    MomentRepository? momentRepository,
    DateRepository? dateRepository,
    ReactionRepository? reactionRepository,
  })  : _coupleRepository = coupleRepository ?? CoupleRepository(),
        _momentRepository = momentRepository ?? MomentRepository(),
        _dateRepository = dateRepository ?? DateRepository(),
        _reactionRepository = reactionRepository ?? ReactionRepository();

  String? _currentCoupleId;
  String? _currentUserId;

  CoupleModel? _couple;
  List<MomentModel> _moments = [];
  List<ImportantDateModel> _dates = [];
  List<ReactionModel> _reactions = [];

  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<List<MomentModel>>? _momentSub;
  StreamSubscription<List<ImportantDateModel>>? _dateSub;
  StreamSubscription<List<ReactionModel>>? _reactionSub;
  StreamSubscription<DocumentSnapshot>? _coupleSub;

  // In-memory cache untuk decode foto Base64 agar tidak freeze UI thread tiap build (H4)
  final Map<String, Uint8List> _decodedImageCache = {};

  CoupleModel? get couple => _couple;
  List<MomentModel> get moments => _moments;
  List<ImportantDateModel> get dates => _dates;
  List<ReactionModel> get reactions => _reactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReactionModel? get partnerReaction {
    if (_currentUserId == null) return null;
    try {
      return _reactions.firstWhere((r) => r.uid != _currentUserId);
    } catch (_) {
      return null;
    }
  }

  ReactionModel? get myReaction {
    if (_currentUserId == null) return null;
    try {
      return _reactions.firstWhere((r) => r.uid == _currentUserId);
    } catch (_) {
      return null;
    }
  }

  List<String> get reactionTags {
    if (_couple?.reactionTags != null && _couple!.reactionTags!.isNotEmpty) {
      return _couple!.reactionTags!.map((e) => e.toString()).toList();
    }
    // Default 4 tag sesuai desain Figma / HTML
    return const ['Peluk', 'Kangen', 'Semangat', 'Hati-hati'];
  }

  MomentModel? get myMoment {
    if (_currentUserId == null) return null;
    try {
      return _moments.firstWhere((m) => m.uid == _currentUserId);
    } catch (_) {
      return null;
    }
  }

  MomentModel? get partnerMoment {
    if (_currentUserId == null) return null;
    try {
      return _moments.firstWhere((m) => m.uid != _currentUserId);
    } catch (_) {
      return null;
    }
  }

  ImportantDateModel? get nearestDate {
    final now = DateTime.now();
    final upcoming = _dates.where((d) => d.daysUntil(now) >= 0).toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.daysUntil(now).compareTo(b.daysUntil(now)));
    return upcoming.first;
  }

  /// Inisialisasi langganan Firestore sekali saat user & coupleId tersedia
  void initialize({required String userId, required String? coupleId}) {
    if (_currentCoupleId == coupleId && _currentUserId == userId) return;

    _currentUserId = userId;
    _currentCoupleId = coupleId;

    _momentSub?.cancel();
    _dateSub?.cancel();
    _reactionSub?.cancel();
    _coupleSub?.cancel();

    if (coupleId == null || coupleId.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _loadCoupleAndSubscribe(coupleId);
  }

  Future<void> _loadCoupleAndSubscribe(String coupleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _couple = await _coupleRepository.getCouple(coupleId);

      // 1. Langganan stream Moments sekali
      _momentSub = _momentRepository.observeCoupleMoments(coupleId: coupleId).listen(
        (momentsList) {
          _moments = momentsList;
          _updateImageCache(momentsList);
          _syncNativeWidget();
          notifyListeners();
        },
        onError: (err) {
          debugPrint('[HomeProvider] Moment stream error: $err');
        },
      );

      // 2. Langganan stream Important Dates sekali
      _dateSub = _dateRepository.observeDates(coupleId: coupleId).listen(
        (datesList) {
          _dates = datesList;
          _syncNativeWidget();
          notifyListeners();
        },
        onError: (err) {
          debugPrint('[HomeProvider] Date stream error: $err');
        },
      );

      // 3. Langganan stream Reactions sekali
      _reactionSub = _reactionRepository.getReactionsStream(coupleId).listen(
        (reactionsList) {
          _reactions = reactionsList;
          notifyListeners();
        },
        onError: (err) {
          debugPrint('[HomeProvider] Reaction stream error: $err');
        },
      );

      // 4. Langganan dokumen Couple untuk live update reactionTags
      _coupleSub = FirebaseFirestore.instance
          .collection('couples')
          .doc(coupleId)
          .snapshots()
          .listen(
        (snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            _couple = CoupleModel.fromMap(snapshot.id, snapshot.data()!);
            notifyListeners();
          }
        },
        onError: (err) {
          debugPrint('[HomeProvider] Couple stream error: $err');
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateImageCache(List<MomentModel> momentsList) {
    for (final m in momentsList) {
      if (m.photoBase64.isNotEmpty) {
        final cacheKey = '${m.uid}_${m.updatedAt.millisecondsSinceEpoch}';
        if (!_decodedImageCache.containsKey(cacheKey)) {
          try {
            _decodedImageCache[cacheKey] = base64Decode(m.photoBase64);
          } catch (_) {}
        }
      }
    }
  }

  Uint8List? getCachedImage(MomentModel moment) {
    final cacheKey = '${moment.uid}_${moment.updatedAt.millisecondsSinceEpoch}';
    if (_decodedImageCache.containsKey(cacheKey)) {
      return _decodedImageCache[cacheKey];
    }
    try {
      final bytes = base64Decode(moment.photoBase64);
      _decodedImageCache[cacheKey] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  /// Sinkronisasi widget native homescreen satu kali dengan data lengkap (H5)
  void _syncNativeWidget() {
    WidgetSyncManager.syncWidget(
      partnerMoment: partnerMoment,
      myMoment: myMoment,
      dates: _dates,
    );
  }

  /// Kirim reaksi instan ke pasangan
  Future<void> sendReaction(String tag) async {
    if (_currentCoupleId == null || _currentUserId == null) return;
    try {
      await _reactionRepository.sendReaction(
        coupleId: _currentCoupleId!,
        uid: _currentUserId!,
        tag: tag,
      );
    } catch (e) {
      debugPrint('[HomeProvider] Failed to send reaction: $e');
    }
  }

  /// Update daftar custom tag balasan (maksimal 6 tag)
  Future<void> updateReactionTags(List<String> tags) async {
    if (_currentCoupleId == null) return;
    try {
      await _coupleRepository.updateReactionTags(_currentCoupleId!, tags);
    } catch (e) {
      debugPrint('[HomeProvider] Failed to update reaction tags: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _momentSub?.cancel();
    _dateSub?.cancel();
    _reactionSub?.cancel();
    _coupleSub?.cancel();
    super.dispose();
  }
}
