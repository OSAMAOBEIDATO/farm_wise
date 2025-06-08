import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/Components/SnakBar.dart';
import 'package:flutter/material.dart';

class ReusableButton extends StatelessWidget {
  ReusableButton(
      {super.key, required this.emailController,
      required this.passwordController,
      required this.onTap,
      required this.isLoading,
      required this.label});

  TextEditingController passwordController;
  TextEditingController emailController;
  bool isLoading = false;
  String label ="";
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (emailController.text.isEmpty ||
              passwordController.text.isEmpty) {
            CustomSnackBar().ShowSnackBar(
              context: context,
              text: "Please fill in all fields",
            );
          } else {
            onTap();
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.grey[100],
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.green)
            : Text(label, style: KTextStyle),
      ),
    );
  }
}
