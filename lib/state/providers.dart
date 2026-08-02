import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/audio_controller.dart';
import '../core/persistence/local_store.dart';
import '../core/rive/costume_bridge.dart';
import '../data/mock_data.dart';
import '../data/models.dart';

/// The persistence layer, provided at boot via [ProviderScope] overrides.
final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('localStoreProvider must be overridden at boot');
});

/// Global audio controller (3-channel). Loads persisted levels once.
final audioProvider = ChangeNotifierProvider<AudioController>((ref) {
  final store = ref.watch(localStoreProvider);
  final audio = AudioController();
  for (final c in AudioChannel.values) {
    audio.state(c).volume = store.audioLevel(c.key, audio.state(c).volume);
  }
  return audio;
});

/// The Rive costume bridge (skin swap + reactions).
final costumeBridgeProvider = ChangeNotifierProvider<CostumeBridge>((ref) {
  final bridge = CostumeBridge();
  final store = ref.watch(localStoreProvider);
  final equipped = store.equippedCostumeId;
  if (equipped != null) {
    final c = kCostumes.firstWhere(
      (e) => e.id == equipped,
      orElse: () => kCostumes.first,
    );
    bridge.equipSkin(c.id, c.color);
  }
  return bridge;
});

/// Progress snapshot: derived from the store, refreshed by [ProgressController].
class ProgressState {
  const ProgressState({
    required this.starsByLesson,
    required this.unlocked,
    required this.equippedId,
  });

  final Map<String, int> starsByLesson;
  final Set<String> unlocked;
  final String? equippedId;

  int get totalStars =>
      starsByLesson.values.fold(0, (a, b) => a + b);
  int get completedCount =>
      starsByLesson.values.where((s) => s > 0).length;

  bool isCompleted(String lessonId) => (starsByLesson[lessonId] ?? 0) > 0;
  int starsFor(String lessonId) => starsByLesson[lessonId] ?? 0;

  /// A costume is available if explicitly unlocked or affordable by stars.
  bool isAvailable(Costume c) =>
      unlocked.contains(c.id) || totalStars >= c.starCost;

  /// The first not-yet-completed lesson (the "continue" target).
  int get currentIndex {
    for (int i = 0; i < kLessons.length; i++) {
      if (!isCompleted(kLessons[i].id)) return i;
    }
    return kLessons.length - 1;
  }

  ProgressState copyWith({
    Map<String, int>? starsByLesson,
    Set<String>? unlocked,
    String? equippedId,
  }) =>
      ProgressState(
        starsByLesson: starsByLesson ?? this.starsByLesson,
        unlocked: unlocked ?? this.unlocked,
        equippedId: equippedId ?? this.equippedId,
      );
}

class ProgressController extends StateNotifier<ProgressState> {
  ProgressController(this._store)
      : super(ProgressState(
          starsByLesson: {
            for (final l in kLessons) l.id: _store.starsFor(l.id),
          },
          unlocked: {
            for (final c in kCostumes)
              if (_store.isUnlocked(c.id)) c.id,
          },
          equippedId: _store.equippedCostumeId,
        ));

  final LocalStore _store;

  Future<void> completeLesson(String lessonId, int stars) async {
    await _store.recordStars(lessonId, stars);
    // Auto-unlock any costume the new star total now affords.
    final total = _store.totalStars;
    for (final c in kCostumes) {
      if (total >= c.starCost && !_store.isUnlocked(c.id)) {
        await _store.unlock(c.id);
      }
    }
    _refresh();
  }

  Future<void> equip(String costumeId) async {
    await _store.setEquipped(costumeId);
    _refresh();
  }

  Future<void> reset() async {
    await _store.resetProgress();
    _refresh();
    if (kDebugMode) debugPrint('[progress] reset');
  }

  void _refresh() {
    state = ProgressState(
      starsByLesson: {for (final l in kLessons) l.id: _store.starsFor(l.id)},
      unlocked: {
        for (final c in kCostumes)
          if (_store.isUnlocked(c.id)) c.id
      },
      equippedId: _store.equippedCostumeId,
    );
  }
}

final progressProvider =
    StateNotifierProvider<ProgressController, ProgressState>((ref) {
  return ProgressController(ref.watch(localStoreProvider));
});
