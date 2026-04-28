import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class buildTextField extends StatelessWidget{
TextEditingController controller;
String hint;
IconData icon;
bool? obscure;
   buildTextField({super.key,required this.controller,  this.obscure ,required this.hint,required this.icon});
  @override
  Widget build(BuildContext context) {

    return TextField(
      controller: controller,
      obscureText:obscure==null?false:true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.black,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),

    );
  }

}