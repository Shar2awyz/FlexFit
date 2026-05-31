import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled6/Pages/Components/app_route.dart';
import 'package:untitled6/theme/app_colors.dart';
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
              child: CustomSearchBar(
                controller: _searchController,
                onChanged: vm.filterBySearch,
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
                                subtitle: e.muscleGroup,
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
