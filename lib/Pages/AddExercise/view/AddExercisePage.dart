import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_fit/Pages/Components/app_route.dart';
import 'package:flex_fit/theme/app_colors.dart';
import '../AddExerciseRepository.dart';
import '../viewmodel/AddExerciseViewModel.dart';
import '../Components/CategoryChip.dart';
import '../Components/ExerciseItem.dart';
import '../Components/SearchBar.dart';
import '../Components/TopBar.dart';
import 'FinishPage.dart';

class AddExercise extends StatelessWidget {
  final bool pickMode;
  final String? splitId;

  const AddExercise({super.key, this.pickMode = false, this.splitId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddExerciseViewModel(AddExerciseRepository())
        ..loadExercises(),
      child: _AddExerciseView(pickMode: pickMode, splitId: splitId),
    );
  }
}

class _AddExerciseView extends StatefulWidget {
  final bool pickMode;
  final String? splitId;

  const _AddExerciseView({required this.pickMode, required this.splitId});

  @override
  State<_AddExerciseView> createState() => _AddExerciseViewState();
}

class _AddExerciseViewState extends State<_AddExerciseView> {
  final _searchController = TextEditingController();

  static const _categories = [
    'All', 'Chest', 'Back', 'Legs', 'Arms', 'Core', 'Shoulder',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getCategoryIndex(String muscle) {
    return _categories.indexWhere((c) => c.toLowerCase() == muscle.toLowerCase());
  }

  Widget _buildFilterButton(BuildContext context, AddExerciseViewModel vm) {
    final hasActiveFilters = vm.selectedMuscle != 'All' || vm.selectedEquipment != 'All';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _showFilterBottomSheet(context, vm),
          child: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: context.border, width: 1),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: hasActiveFilters ? context.accentLight : context.textPrimary,
              size: 20,
            ),
          ),
        ),
        if (hasActiveFilters)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context, AddExerciseViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.pageBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final muscles = vm.availableMuscles;
            final equipments = vm.availableEquipments;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Exercises',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            vm.clearFilters();
                            setModalState(() {});
                          },
                          child: Text(
                            'Clear All',
                            style: TextStyle(color: context.accentLight),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Muscle Group',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: muscles.length,
                        itemBuilder: (context, idx) {
                          final muscle = muscles[idx];
                          final isSelected = vm.selectedMuscle.toLowerCase() == muscle.toLowerCase();
                          return CategoryChip(
                            label: muscle,
                            selected: isSelected,
                            onTap: () {
                              vm.filterByCategory(muscle, _getCategoryIndex(muscle));
                              setModalState(() {});
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Equipment',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: equipments.length,
                        itemBuilder: (context, idx) {
                          final equipment = equipments[idx];
                          final isSelected = vm.selectedEquipment.toLowerCase() == equipment.toLowerCase();
                          return CategoryChip(
                            label: equipment,
                            selected: isSelected,
                            onTap: () {
                              vm.filterByEquipment(equipment);
                              setModalState(() {});
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.accentLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddExerciseViewModel>();

    return Scaffold(
      backgroundColor: context.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onBack: () => Navigator.pop(context),
              onFinish: () {
                if (widget.pickMode) {
                  final picked = vm.selectedExercises
                      .map((e) => {
                            'id': e.id,
                            'name': e.name,
                            'muscle_group': e.muscleGroup,
                            'equipment': e.equipment,
                            'photo_url': e.photoUrl ?? '',
                          })
                      .toList();
                  Navigator.pop(context, picked);
                } else {
                  Navigator.push(
                    context,
                    appRoute((_) => FinishPage(
                          exercises: vm.selectedExercises,
                          splitId: widget.splitId,
                        )),
                  );
                }
              },
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchBar(
                      controller: _searchController,
                      onChanged: vm.filterBySearch,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterButton(context, vm),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _categories.length,
                itemBuilder: (context, index) => CategoryChip(
                  label: _categories[index],
                  selected: vm.selectedCategoryIndex == index,
                  onTap: () =>
                      vm.filterByCategory(_categories[index], index),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.filteredExercises.isEmpty
                        ? const Center(child: Text('No exercises found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: vm.filteredExercises.length,
                            itemBuilder: (context, index) {
                              final e = vm.filteredExercises[index];
                              return ExerciseItem(
                                title: e.name,
                                subtitle: e.equipment.isNotEmpty
                                    ? '${e.muscleGroup} • ${e.equipment}'
                                    : e.muscleGroup,
                                image: e.photoUrl ?? '',
                                isSelected: vm.isSelected(e.id),
                                onAdd: () => vm.toggleExercise(e),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
