import 'package:flutter/material.dart';
import '../../model/ExerciseWithSets.dart';
import '../../viewmodel/cubit/WorkoutBeginCubit.dart';

class ExerciseCard extends StatefulWidget {
  final ExerciseWithSets exercise;
  final int index;
  final WorkoutBeginCubit cubit;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    required this.cubit,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {

  final List<TextEditingController> weightControllers = [];
  final List<TextEditingController> repsControllers = [];

  @override
  void initState() {
    super.initState();

    /// أول row
    _addControllers();
  }

  void _addControllers() {
    weightControllers.add(TextEditingController());
    repsControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    for (var c in weightControllers) c.dispose();
    for (var c in repsControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          /// 🔹 Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exercise.name,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16),
              ),
              const Icon(Icons.more_vert, color: Colors.white),
            ],
          ),

          const SizedBox(height: 10),

          /// 🔹 Sets
          Column(
            children: List.generate(weightControllers.length, (i) {

              String hint = "kg";

              if (i < exercise.previousSets.length) {
                final prev = exercise.previousSets[i];
                hint = "${prev.weight}kg × ${prev.reps}";
              }

              return Row(
                children: [

                  /// Weight
                  Expanded(
                    child: TextField(
                      controller: weightControllers[i],
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle:
                        const TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// Reps
                  Expanded(
                    child: TextField(
                      controller: repsControllers[i],
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Reps",
                        hintStyle:
                        TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),

                  /// ✔ Save Set
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {

                      final weight = double.tryParse(
                          weightControllers[i].text) ??
                          0;

                      final reps = int.tryParse(
                          repsControllers[i].text) ??
                          0;

                      if (weight == 0 || reps == 0) return;

                      widget.cubit.addSet(
                        exerciseIndex: widget.index,
                        reps: reps,
                        weight: weight,
                      );


                      weightControllers[i].clear();
                      repsControllers[i].clear();
                    },
                  ),
                ],
              );
            }),
          ),

          /// 🔹 Add Set Button
          TextButton(
            onPressed: () {
              setState(() {
                _addControllers();
              });
            },
            child: const Text(
              "+ Add Set",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}