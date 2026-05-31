import 'package:flutter/material.dart';
import '../AddExerciseRepository.dart';
import '../model/ExerciseListItem.dart';

class AddExerciseViewModel extends ChangeNotifier {
  final AddExerciseRepository _repo;

  AddExerciseViewModel(this._repo);

  List<ExerciseListItem> _allExercises = [];
  List<ExerciseListItem> filteredExercises = [];
  List<ExerciseListItem> selectedExercises = [];

  bool isLoading = true;
  String selectedMuscle = 'All';
  String searchText = '';
  int selectedCategoryIndex = 0;

  Future<void> loadExercises() async {
    isLoading = true;
    notifyListeners();
    _allExercises = await _repo.getAllExercises();
    filteredExercises = List.from(_allExercises);
    isLoading = false;
    notifyListeners();
  }

  void filterByCategory(String muscle, int index) {
    selectedMuscle = muscle;
    selectedCategoryIndex = index;
    _applyFilters();
  }

  void filterBySearch(String query) {
    searchText = query;
    _applyFilters();
  }

  void toggleExercise(ExerciseListItem exercise) {
    final idx = selectedExercises.indexWhere((e) => e.id == exercise.id);
    if (idx != -1) {
      selectedExercises.removeAt(idx);
    } else {
      selectedExercises.add(exercise);
    }
    notifyListeners();
  }

  bool isSelected(String id) => selectedExercises.any((e) => e.id == id);

  void _applyFilters() {
    filteredExercises = _allExercises.where((e) {
      final matchesMuscle = selectedMuscle == 'All' ||
          e.muscleGroup.toLowerCase().contains(selectedMuscle.toLowerCase());
      final matchesSearch =
          e.name.toLowerCase().contains(searchText.toLowerCase());
      return matchesMuscle && matchesSearch;
    }).toList();
    notifyListeners();
  }
}
