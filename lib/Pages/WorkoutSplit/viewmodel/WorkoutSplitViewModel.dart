import 'package:flutter/material.dart';
import '../WorkoutSplitRepository.dart';

class WorkoutSplitViewModel extends ChangeNotifier {
  final WorkoutSplitRepository _repo;
  final String userId;

  WorkoutSplitViewModel(this._repo, {required this.userId});

  String? splitId;
  List<Map<String, dynamic>> days = [];
  bool isLoading = false;

  Future<void> loadDays() async {
    if (splitId == null) return;
    isLoading = true;
    notifyListeners();
    days = await _repo.getDays(splitId!);
    isLoading = false;
    notifyListeners();
  }

  Future<String> ensureSplitCreated(String name) async {
    splitId ??= await _repo.createSplit(
      userId,
      name.trim().isEmpty ? 'My Split' : name.trim(),
    );
    notifyListeners();
    return splitId!;
  }

  Future<void> deleteDay(String dayId, int index) async {
    days.removeAt(index);
    notifyListeners();
    await _repo.deleteDay(dayId);
  }
}
