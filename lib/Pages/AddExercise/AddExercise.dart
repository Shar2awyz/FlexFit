import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled6/Pages/AddExercise/Finish.dart';

import '../Components/CustomBottomNavBar.dart';
import '../Components/app_route.dart';
import 'Components/CategoryChip.dart';
import 'Components/ExerciseItem.dart';
import 'Components/SearchBar.dart';
import 'Components/TopBar.dart';

class AddExercise extends StatefulWidget {
  /// When true, "Finish" pops with the selected exercises instead of
  /// navigating to the split-creation flow.
  final bool pickMode;

  /// When set (and pickMode is false), exercises are added as a new day
  /// to this existing split rather than creating a brand-new split.
  final String? splitId;

  const AddExercise({super.key, this.pickMode = false, this.splitId});

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  final TextEditingController controller = TextEditingController();

  List<dynamic> allExercises = [];
  List<dynamic> filteredExercises = [];

  bool isLoading = true;

  int selectedCategory = 0;
  int bottomIndex = 2;

  String selectedMuscle = "All";
  String searchText = "";

  final List<String> categories = [
    "All","Chest","Back","Legs","Arms","Core","Shoulder"
  ];
  final List<String> selectedexercises=[];
  final List<String>selectedexercisephoto=[];
  final List<String>selectedexercisemuscle=[];
  final List<String>selectedexerciseids=[];


  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await Supabase.instance.client
        .from('exercises')
        .select();

    allExercises = data;
    filteredExercises = data;

    setState(() {
      isLoading = false;
    });
  }

  void applyFilters() {
    filteredExercises = allExercises.where((e) {
      final matchesMuscle = selectedMuscle == "All" ||
          e['muscle_group']
              .toLowerCase()
              .contains(selectedMuscle.toLowerCase());

      final matchesSearch = e['name']
          .toLowerCase()
          .contains(searchText.toLowerCase());

      return matchesMuscle && matchesSearch;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onBack: () => Navigator.pop(context),
              onFinish: () {
                if (widget.pickMode) {
                  final picked = List.generate(
                    selectedexerciseids.length,
                    (i) => {
                      'id': selectedexerciseids[i],
                      'name': selectedexercises[i],
                      'muscle_group': selectedexercisemuscle[i],
                      'photo_url': selectedexercisephoto[i],
                    },
                  );
                  Navigator.pop(context, picked);
                } else {
                  Navigator.push(
                    context,
                    appRoute( (context) => Finish(
                        exercises: selectedexercises,
                        muscle: selectedexercisemuscle,
                        photo: selectedexercisephoto,
                        id: selectedexerciseids,
                        splitId: widget.splitId,
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomSearchBar(
                controller: controller,
                onChanged: (v) {
                  searchText = v;
                  applyFilters();
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryChip(
                    label: categories[index],
                    selected: selectedCategory == index,
                    onTap: () {
                      setState(() {
                        selectedCategory = index;
                        selectedMuscle = categories[index];
                      });

                      applyFilters(); // 🔥 local filter
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredExercises.isEmpty
                    ? const Center(child: Text("No exercises found"))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final e = filteredExercises[index];

                    return ExerciseItem(
                      title: e["name"],
                      subtitle: e["muscle_group"],
                      image: e["photo_url"],
                      onAdd: () {
                        final idx = selectedexerciseids.indexOf(e['id']);
                        if (idx != -1) {
                          selectedexerciseids.removeAt(idx);
                          selectedexercises.removeAt(idx);
                          selectedexercisephoto.removeAt(idx);
                          selectedexercisemuscle.removeAt(idx);
                        } else {
                          selectedexerciseids.add(e['id']);
                          selectedexercises.add(e['name']);
                          selectedexercisephoto.add(e['photo_url']);
                          selectedexercisemuscle.add(e['muscle_group']);
                        }
                      },
                    );
                  },
                ),
              ),
            ),

            if (!widget.pickMode)
              CustomBottomNavBar(
                currentIndex: bottomIndex,
                onTap: (i) {
                  setState(() {
                    bottomIndex = i;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}