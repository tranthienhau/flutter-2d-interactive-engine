import 'package:hive_flutter/hive_flutter.dart';

/// Local, backend-free persistence layer.
///
/// Tracks lesson completion (best star score per lesson) and costume unlocks
/// in two Hive boxes. Survives app restarts with no network. A single
/// [LocalStore] instance is created at boot and injected via Riverpod.
class LocalStore {
  LocalStore._(this._progress, this._unlocks, this._prefs);

  static const _progressBox = 'progress';
  static const _unlocksBox = 'unlocks';
  static const _prefsBox = 'prefs';

  final Box<int> _progress; // lessonId -> best stars (0..3)
  final Box<bool> _unlocks; // costumeId -> unlocked
  final Box _prefs; // misc: child name, equipped costume, audio levels

  /// Opens Hive and the three boxes. Call once before runApp.
  static Future<LocalStore> open() async {
    await Hive.initFlutter();
    final progress = await Hive.openBox<int>(_progressBox);
    final unlocks = await Hive.openBox<bool>(_unlocksBox);
    final prefs = await Hive.openBox(_prefsBox);
    return LocalStore._(progress, unlocks, prefs);
  }

  // ----- Lesson progress -------------------------------------------------

  int starsFor(String lessonId) => _progress.get(lessonId, defaultValue: 0)!;

  bool isCompleted(String lessonId) => starsFor(lessonId) > 0;

  /// Records a run; only keeps the best score so replays never lower a star.
  Future<void> recordStars(String lessonId, int stars) async {
    if (stars > starsFor(lessonId)) {
      await _progress.put(lessonId, stars);
    }
  }

  int get totalStars =>
      _progress.values.fold<int>(0, (sum, s) => sum + s);

  int get completedCount =>
      _progress.values.where((s) => s > 0).length;

  // ----- Costume unlocks -------------------------------------------------

  bool isUnlocked(String costumeId) =>
      _unlocks.get(costumeId, defaultValue: false)!;

  Future<void> unlock(String costumeId) => _unlocks.put(costumeId, true);

  // ----- Misc prefs ------------------------------------------------------

  String get childName => _prefs.get('childName', defaultValue: 'Friend') as String;
  Future<void> setChildName(String v) => _prefs.put('childName', v);

  String? get buddyId => _prefs.get('buddyId') as String?;
  Future<void> setBuddy(String id) => _prefs.put('buddyId', id);

  String? get equippedCostumeId => _prefs.get('equipped') as String?;
  Future<void> setEquipped(String id) => _prefs.put('equipped', id);

  bool get onboarded => _prefs.get('onboarded', defaultValue: false) as bool;
  Future<void> setOnboarded() => _prefs.put('onboarded', true);

  double audioLevel(String channel, double fallback) =>
      (_prefs.get('audio_$channel', defaultValue: fallback) as num).toDouble();
  Future<void> setAudioLevel(String channel, double v) =>
      _prefs.put('audio_$channel', v);

  Future<void> resetProgress() async {
    await _progress.clear();
    await _unlocks.clear();
  }
}
