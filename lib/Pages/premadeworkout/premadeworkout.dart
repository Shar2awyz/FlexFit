import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled6/Pages/premadeworkout/Components/WorkoutDayCard.dart';
import 'package:untitled6/Pages/premadeworkout/Components/headersection.dart';

class PremadeWorkout extends StatefulWidget {
  final String splitid;

  const PremadeWorkout({super.key, required this.splitid});

  @override
  State<PremadeWorkout> createState() => _PremadeWorkoutState();
}

class _PremadeWorkoutState extends State<PremadeWorkout> {
  late Future<Map<String, dynamic>> _future;

  /// 🔥 Load ALL data (split + days + exercises)
  Future<Map<String, dynamic>> loaddata() async {
    final data = await Supabase.instance.client
        .from('premade_splits')
        .select('''
  id,
  name,
  description,
  premade_split_days!fk_split (
    id,
    name,
    day_order,
    premade_split_exercises (
      order_index,
      exercises (
        id,
        name
      )
    )
  )
''')
        .eq('id', widget.splitid)
        .single();
    print(data);
    return data;
  }

  @override
  void initState() {
    super.initState();
    _future = loaddata();
    print("SPLIT ID FROM APP: ${widget.splitid}");
    print("APP ID: ${widget.splitid}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: const Text("Workout Program"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          /// 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset(
                'animation/Icon gym for Sporttler.json',
                width: 100,
                height: 100,
              ),
            );
          }

          /// ❌ Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          /// ❌ No data
          if (!snapshot.hasData) {
            return const Center(
              child: Text("No Data", style: TextStyle(color: Colors.white)),
            );
          }

          final data = snapshot.data!;

          /// 🔹 Split Info
          final String name = data['name'] ?? 'No Name';
          final String desc = data['description'] ?? '';

          /// 🔹 Days List (SAFE)
          final List days = data['premade_split_days'] ?? [];

          /// 🔹 Sort days by order
          days.sort((a, b) =>
              (a['day_order'] ?? 0).compareTo(b['day_order'] ?? 0));

          return Column(
            children: [
              /// 🔹 Header
              HeaderSection(title: name, description: desc),

              const SizedBox(height: 10),

              /// 🔹 Days List
              Expanded(
                child: days.isEmpty
                    ? const Center(
                  child: Text(
                    "No Days Found",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];

                    /// 🔹 Exercises List (SAFE)
                    final List exList =
                        day['premade_split_exercises'] ?? [];

                    final exercises = exList
                        .map<String>((e) =>
                    e['exercises']?['name'] ?? 'No Name')
                        .toList();

                    /// 🔍 Debug (اختياري)
                    print("DAY: ${day['name']}");
                    print("EXERCISES: $exercises");

                    return WorkoutDayCard(
                      day: "Day ${day['day_order'] ?? index + 1}",
                      title: day['name'] ?? 'No Name',
                      exercises: exercises,
                    );
                    
                  },
                ),
                
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(

                  onTap: () async {
                    final supabase = Supabase.instance.client;

                    final data = await _future;

                    /// 1) INSERT NEW SPLIT
                    final newSplit = await supabase
                        .from('workout_splits')
                        .insert({
                      'name': data['name'],
                      'user_id': supabase.auth.currentUser!.id,
                    })
                        .select()
                        .single();

                    final newSplitId = newSplit['id'];

                    /// 2) LOOP DAYS
                    final List days = data['premade_split_days'] ?? [];

                    for (var day in days) {
                      final newDay = await supabase
                          .from('split_days')
                          .insert({
                        'name': day['name'],
                        'day_order': day['day_order'],
                        'split_id': newSplitId,
                      })
                          .select()
                          .single();

                      final newDayId = newDay['id'];

                      /// 3) LOOP EXERCISES
                      final List exList = day['premade_split_exercises'] ?? [];

                      for (var ex in exList) {
                        await supabase.from('split_exercises').insert({
                          'split_day_id': newDayId,
                          'exercise_id': ex['exercises']['id'], // 🔥 مهم
                          'order_index': ex['order_index'],
                        });
                      }
                    }


                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Routine Saved Successfully")),
                    );

                    Navigator.pop(context);
                  },
                  child: Container(

                    width: double.infinity,
                    height: 60,

                    decoration: BoxDecoration( color:  Colors.blueAccent,borderRadius: BorderRadius.circular(20)),
                  child: Center(child: Text('Save Routine',style: TextStyle(color: Colors.white),),),
                  ),
                ),
              )

        
            ],
          );
        },
      ),



    );
  }
}