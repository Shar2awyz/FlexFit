import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_fit/Pages/AddExercise/Components/FinalComponent.dart';
import 'package:flex_fit/Pages/Components/app_route.dart';
import 'package:flex_fit/Pages/StartWorkout/view/StartWorkoutPage.dart';
import '../model/ExerciseListItem.dart';

class FinishPage extends StatefulWidget {
  final List<ExerciseListItem> exercises;
  final String? splitId;

  const FinishPage({
    super.key,
    required this.exercises,
    this.splitId,
  });

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  late List<ExerciseListItem> _exercises;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.exercises);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final supabase = Supabase.instance.client;
    final dayName =
        _nameController.text.trim().isEmpty ? 'Day' : _nameController.text.trim();

    try {
      final userId = supabase.auth.currentUser!.id;
      String resolvedSplitId;

      if (widget.splitId != null) {
        resolvedSplitId = widget.splitId!;
      } else {
        final splitRes = await supabase
            .from('workout_splits')
            .insert({'user_id': userId, 'name': dayName})
            .select()
            .single();
        resolvedSplitId = splitRes['id'] as String;
      }

      final existingDays = await supabase
          .from('split_days')
          .select('id')
          .eq('split_id', resolvedSplitId);
      final dayOrder = (existingDays as List).length + 1;

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

      await supabase.from('split_exercises').insert([
        for (int i = 0; i < _exercises.length; i++)
          {
            'split_day_id': dayId,
            'exercise_id': _exercises[i].id,
            'order_index': i + 1,
          }
      ]);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved successfully')),
      );

      if (widget.splitId != null) {
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          appRoute((_) => StartWorkout(userid: userId)),
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
        centerTitle: true,
        title: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.splitId != null
                ? 'Enter Day Name'
                : 'Enter Split Name',
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _exercises.isEmpty
                ? const Center(
                    child: Text('No exercises selected',
                        style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final e = _exercises[index];
                      return FinalComponent(
                        name: e.name,
                        muscle: e.muscleGroup,
                        imageUrl: e.photoUrl ?? '',
                        onDelete: () =>
                            setState(() => _exercises.removeAt(index)),
                      );
                    },
                  ),
          ),
          GestureDetector(
            onTap: _save,
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
                    'SAVE & START SPLIT',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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
