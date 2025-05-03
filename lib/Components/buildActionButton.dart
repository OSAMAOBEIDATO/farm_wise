import 'package:flutter/material.dart';

Widget buildActionButton({required String label,required Function() onTap,double fontSize = 20}) {

  return InkWell (
    onTap: onTap,
    child: Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        ),
      ),
    ),
  );
}
