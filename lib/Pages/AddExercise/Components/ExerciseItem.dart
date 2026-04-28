import 'package:flutter/material.dart';

class ExerciseItem extends StatefulWidget {
  final String title;
  final String subtitle;
  
  final VoidCallback onAdd;
  final String image;
  const ExerciseItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onAdd,
    required this.image
  });

  @override
  State<ExerciseItem> createState() => _ExerciseItemState();
}

class _ExerciseItemState extends State<ExerciseItem> {
  bool isAdded = false;

  void toggle() {
    setState(() {
      isAdded = !isAdded;
    });

    widget.onAdd(); // ✅ call callback
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
         ClipRRect(

           borderRadius: BorderRadius.circular(30),
           child: 
           Image.network(this.widget.image,width: 30,height :30),
           
         ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: toggle,
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isAdded ? Icons.remove : Icons.add,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}