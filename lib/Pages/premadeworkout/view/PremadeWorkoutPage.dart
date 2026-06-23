import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_fit/Pages/premadeworkout/Components/WorkoutDayCard.dart';
import 'package:flex_fit/Pages/premadeworkout/Components/headersection.dart';
import '../PremadeWorkoutRepository.dart';
import '../model/PremadeSplitModel.dart';
import '../viewmodel/PremadeWorkoutViewModel.dart';

class PremadeWorkout extends StatefulWidget {
  final String splitid;

  const PremadeWorkout({super.key, required this.splitid});

  @override
  State<PremadeWorkout> createState() => _PremadeWorkoutState();
}

class _PremadeWorkoutState extends State<PremadeWorkout> {
  late final PremadeWorkoutViewModel _vm;
  late Future<PremadeSplitModel> _future;

  @override
  void initState() {
    super.initState();
    _vm = PremadeWorkoutViewModel(PremadeWorkoutRepository());
    _future = _vm.loadSplit(widget.splitid);
  }

  Future<void> _saveRoutine(PremadeSplitModel split) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    await _vm.saveRoutine(split, userId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Routine Saved Successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: const Text('Workout Program'),
      ),
      body: FutureBuilder<PremadeSplitModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset(
                'animation/Icon gym for Sporttler.json',
                width: 100,
                height: 100,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No Data', style: TextStyle(color: Colors.white)),
            );
          }

          final split = snapshot.data!;

          return Column(
            children: [
              HeaderSection(title: split.name, description: split.description),
              const SizedBox(height: 10),
              Expanded(
                child: split.days.isEmpty
                    ? const Center(
                        child: Text('No Days Found',
                            style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: split.days.length,
                        itemBuilder: (context, index) {
                          final day = split.days[index];
                          final exercises =
                              day.exercises.map((e) => e.name).toList();
                          return WorkoutDayCard(
                            day: 'Day ${day.dayOrder}',
                            title: day.name,
                            exercises: exercises,
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () => _saveRoutine(split),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Save Routine',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
