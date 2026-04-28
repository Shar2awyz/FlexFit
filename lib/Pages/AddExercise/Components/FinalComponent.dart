import 'package:flutter/material.dart';

class FinalComponent extends StatefulWidget {
  final String name;
  final String muscle;
  final String imageUrl;
  final VoidCallback onDelete;

  const FinalComponent({
    super.key,
    required this.name,
    required this.muscle,
    required this.imageUrl,
    required this.onDelete,
  });

  @override
  State<FinalComponent> createState() => _FinalComponentState();
}

class _FinalComponentState extends State<FinalComponent> {
  bool isExpanded = false;

  List<Map<String, dynamic>> sets = [
    {"reps": "", "weight": ""},
  ];

  void addSet() {
    setState(() {
      sets.add({"reps": "", "weight": ""});
    });
  }

  void removeSet(int index) {
    setState(() {
      sets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E5AA8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          /// HEADER
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported, color: Colors.white),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(widget.muscle,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

              /// EXPAND BUTTON
              IconButton(
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),

              /// DELETE EXERCISE
              GestureDetector(
                onTap: widget.onDelete,
                child: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),

          /// SETS SECTION
          if (isExpanded) ...[
            const SizedBox(height: 10),

            /// LIST OF SETS
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sets.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(index.toString()),

                  direction: DismissDirection.endToStart,

                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  onDismissed: (_) => removeSet(index),

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Row(
                      children: [

                        /// SET NUMBER
                        Text(
                          "Set ${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),

                        const SizedBox(width: 10),

                        /// REPS
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Reps",
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (val) {
                              sets[index]["reps"] = val;
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// WEIGHT
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Kg",
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (val) {
                              sets[index]["weight"] = val;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            /// ADD SET BUTTON
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: addSet,
                child: const Text(
                  "+ Add Set",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}