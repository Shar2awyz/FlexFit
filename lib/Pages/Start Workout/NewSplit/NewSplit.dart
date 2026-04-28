import 'package:flutter/material.dart';
import 'package:untitled6/Pages/AddExercise/AddExercise.dart';
import '../../Components/app_route.dart';

class NewSplit extends StatefulWidget {
  String userid;
  NewSplit ({super.key,required this.userid});

  @override
  State<NewSplit> createState() => _LogWorkoutState();
}

class _LogWorkoutState extends State<NewSplit> {

  List<Map<String, dynamic>> sets = [
    {"kg": 20, "reps": 12},
    {"kg": 40, "reps": 5},
    {"kg": 55, "reps": 8},
  ];

  void addSet() {
    setState(() {
      sets.add({"kg": 0, "reps": 0});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: const Text(
          "New Split",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Finish",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),

      body: Column(
        children: [

          /// 🔹 Stats Row


          /// 🔹 Exercise Title
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Bench Press (Barbell)",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          /// 🔹 Rest Timer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  "Rest Timer: 2:00",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
//sharkawy ostora walahy w ely ma3ah ma4ta8aloo4 bgneh awelhom George
          const SizedBox(height: 10),

          /// 🔹 Table Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("SET", style: TextStyle(color: Colors.white70)),
                Text("KG", style: TextStyle(color: Colors.white70)),
                Text("REPS", style: TextStyle(color: Colors.white70)),
                Icon(Icons.check, color: Colors.white70),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// 🔹 Sets List (WITH Add Set inside)
          Expanded(
            child: ListView.builder(
              itemCount: sets.length + 1,
              itemBuilder: (context, index) {

                /// 🔸 Add Set Row
                if (index == sets.length) {
                  return GestureDetector(
                    onTap: addSet,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F5E8F),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "+ Add Set",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                /// 🔸 Dismissible Set Row
                return Dismissible(
                  key: ValueKey(sets[index]), // 🔑 important

                  direction: DismissDirection.endToStart, // swipe left only

                  onDismissed: (direction) {
                    setState(() {
                      sets.removeAt(index);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Set removed")),
                    );
                  },

                  background: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F5E8F),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        Text("${index + 1}",
                            style: const TextStyle(color: Colors.white)),

                        /// KG
                        SizedBox(
                          width: 50,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "0",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                              sets[index]["kg"] =
                                  int.tryParse(val) ?? 0;
                            },
                          ),
                        ),

                        /// REPS
                        SizedBox(
                          width: 50,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "0",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                              sets[index]["reps"] =
                                  int.tryParse(val) ?? 0;
                            },
                          ),
                        ),

                        const Icon(Icons.check_circle,
                            color: Colors.green),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔹 Bottom Button → Add Exercise
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(context, appRoute( (context)=>AddExercise()));

                },
                child: const Text(
                  "+ Add Exercise",
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.bold,
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

/// 🔹 Stats Widget
class _statItem extends StatelessWidget {
  final String title;
  final String value;

  const _statItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}