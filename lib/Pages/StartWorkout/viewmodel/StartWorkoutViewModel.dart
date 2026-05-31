import 'package:flutter/material.dart';
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
    isLoading = true;
    notifyListeners();
    final results = await Future.wait([
      _repo.getUserSplits(userId),
      _repo.getPremadeSplits(),
    ]);
    splits = results[0] as List<SplitSummaryModel>;
    premadeSplits = results[1] as List<PremadeSplitSummary>;
    isLoading = false;
    notifyListeners();
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
