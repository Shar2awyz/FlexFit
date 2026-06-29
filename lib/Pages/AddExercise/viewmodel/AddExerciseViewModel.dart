import 'package:flutter/material.dart';
import 'package:flex_fit/services/cache_service.dart';
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
  String selectedEquipment = 'All';
  String searchText = '';
  int selectedCategoryIndex = 0;

  List<String> get availableMuscles {
    final set = _allExercises
        .map((e) => e.muscleGroup.trim())
        .where((m) => m.isNotEmpty)
        .toSet();
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  List<String> get availableEquipments {
    final set = _allExercises
        .map((e) => e.equipment.trim())
        .where((eq) => eq.isNotEmpty)
        .toSet();
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  Future<void> loadExercises() async {
    final cached = CacheService.get('add_exercises_list');
    if (cached != null) {
      try {
        _allExercises = (cached as List)
            .map((e) => ExerciseListItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        filteredExercises = List.from(_allExercises);
        isLoading = false;
        notifyListeners();
      } catch (e) {
        print("Error restoring exercises list cache: $e");
      }
    } else {
      isLoading = true;
      notifyListeners();
    }

    try {
      _allExercises = await _repo.getAllExercises();
      filteredExercises = List.from(_allExercises);
      await CacheService.put(
        'add_exercises_list',
        _allExercises.map((e) => e.toJson()).toList(),
      );
    } catch (e) {
      print("Error loading exercises from network: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterByCategory(String muscle, int index) {
    selectedMuscle = muscle;
    selectedCategoryIndex = index;
    _applyFilters();
  }

  void filterByEquipment(String equipment) {
    selectedEquipment = equipment;
    _applyFilters();
  }

  void filterBySearch(String query) {
    searchText = query;
    _applyFilters();
  }

  void clearFilters() {
    selectedMuscle = 'All';
    selectedEquipment = 'All';
    selectedCategoryIndex = 0;
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
      
      final matchesEquipment = selectedEquipment == 'All' ||
          e.equipment.toLowerCase().contains(selectedEquipment.toLowerCase());

      final matchesSearch = searchText.isEmpty ||
          e.name.toLowerCase().contains(searchText.toLowerCase()) ||
          e.muscleGroup.toLowerCase().contains(searchText.toLowerCase()) ||
          e.equipment.toLowerCase().contains(searchText.toLowerCase());

      return matchesMuscle && matchesEquipment && matchesSearch;
    }).toList();
    notifyListeners();
  }
}
