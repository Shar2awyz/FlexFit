import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled6/Pages/AddExercise/Components/FinalComponent.dart';
import 'package:untitled6/Pages/Start%20Workout/NewSplit/NewSplit.dart';
import 'package:untitled6/Pages/Start_Workout.dart';
import '../Components/app_route.dart';

class Finish extends StatefulWidget {
  final List<String> exercises;
  final List<String> photo;
  final List<String> muscle;
  final List<String> id;

  /// When set, a new day is added to this existing split instead of
  /// creating a brand-new split from scratch.
  final String? splitId;

  const Finish({
    super.key,
    required this.exercises,
    required this.photo,
    required this.muscle,
    required this.id,
    this.splitId,
  });

  @override
  State<Finish> createState() => _FinishState();
}

class _FinishState extends State<Finish> {
  late List<Map<String, dynamic>> items;
  TextEditingController fcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();

    items = List.generate(widget.exercises.length, (index) {
      return {
        "name": widget.exercises[index],
        "muscle": widget.muscle[index],
        "photo": widget.photo[index],
      };
    });
  }

  Future<void> saveSplit() async {
    final supabase = Supabase.instance.client;
    final dayName = fcontroller.text.trim().isEmpty ? 'Day' : fcontroller.text.trim();

    try {
      final userId = supabase.auth.currentUser!.id;
      String resolvedSplitId;

      if (widget.splitId != null) {
        // Adding a new day to an existing split — skip split creation.
        resolvedSplitId = widget.splitId!;
      } else {
        // Creating a brand-new split.
        final splitRes = await supabase
            .from('workout_splits')
            .insert({'user_id': userId, 'name': dayName})
            .select()
            .single();
        resolvedSplitId = splitRes['id'] as String;
      }

      // Get current day count so day_order is always correct.
      final existingDays = await supabase
          .from('split_days')
          .select('id')
          .eq('split_id', resolvedSplitId);
      final dayOrder = (existingDays as List).length + 1;

      // Insert the new split day.
      final dayRes = await supabase
          .from('split_days')
          .insert({
            'split_id': resolvedSplitId,
            'name': dayName,
            'day_order': dayOrder,
          })
          .select()
          .single();

      final dayId = dayRes['id'] as String;

      // Insert exercises.
      final List<Map<String, dynamic>> exercisesToInsert = [
        for (int i = 0; i < widget.id.length; i++)
          {
            'split_day_id': dayId,
            'exercise_id': widget.id[i],
            'order_index': i + 1,
          }
      ];

      await supabase.from('split_exercises').insert(exercisesToInsert);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved successfully')),
      );

      if (widget.splitId != null) {
        // Pop both Finish and AddExercise to return to WorkoutRoutine.
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          appRoute( (context) =>
                StartWorkout(userid: supabase.auth.currentUser!.id),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        title: TextField(
          controller: fcontroller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.splitId != null ? 'Enter Day Name' : 'Enter Split Name',
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? const Center(
              child: Text(
                "No exercises selected",
                style: TextStyle(color: Colors.white),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final e = items[index];

                return FinalComponent(
                  name: e["name"],
                  muscle: e["muscle"],
                  imageUrl: e["photo"],

                  onDelete: () {
                    setState(() {
                      items.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),

          /// SAVE BUTTON
          GestureDetector(
            onTap: saveSplit,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "SAVE & START SPLIT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}