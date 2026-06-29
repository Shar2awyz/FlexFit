import 'package:flutter/material.dart';
import 'package:flex_fit/services/cache_service.dart';
import '../StartWorkoutRepository.dart';
import '../model/SplitSummaryModel.dart';

class StartWorkoutViewModel extends ChangeNotifier {
  final StartWorkoutRepository _repo;
  final String userId;

  StartWorkoutViewModel(this._repo, {required this.userId});

  List<SplitSummaryModel> splits = [];
  List<PremadeSplitSummary> premadeSplits = [];
  bool isLoading = false;

  Future<void> loadAll() async {
    final cached = CacheService.get('start_workout_data_$userId');
    if (cached != null) {
      try {
        final cachedSplits = cached['splits'] as List?;
        final cachedPremade = cached['premadeSplits'] as List?;

        if (cachedSplits != null) {
          splits = cachedSplits
              .map((e) => SplitSummaryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        if (cachedPremade != null) {
          premadeSplits = cachedPremade
              .map((e) => PremadeSplitSummary.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        isLoading = false;
        notifyListeners();
      } catch (e) {
        print("Error restoring start workout cache: $e");
      }
    } else {
      isLoading = true;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _repo.getUserSplits(userId),
        _repo.getPremadeSplits(),
      ]);
      splits = results[0] as List<SplitSummaryModel>;
      premadeSplits = results[1] as List<PremadeSplitSummary>;

      await CacheService.put('start_workout_data_$userId', {
        'splits': splits.map((e) => e.toJson()).toList(),
        'premadeSplits': premadeSplits.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      print("Error loading splits from network: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSplit(String splitId) async {
    splits.removeWhere((s) => s.id == splitId);
    notifyListeners();
    await _repo.deleteSplit(splitId);
  }

  Future<void> renameSplit(String splitId, String name) async {
    final idx = splits.indexWhere((s) => s.id == splitId);
    if (idx == -1) return;
    splits[idx] = splits[idx].copyWith(name: name);
    notifyListeners();
    await _repo.renameSplit(splitId, name);
  }
}
