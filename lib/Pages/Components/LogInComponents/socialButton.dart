import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Socialbutton extends StatelessWidget{
IconData icon;
String text;
Socialbutton({super.key,required this.icon,required this.text});
  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }}