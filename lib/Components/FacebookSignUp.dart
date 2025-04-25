import 'package:farm_wise/Common/Constant.dart';
import 'package:flutter/material.dart';

class SignInWithFacebook extends StatelessWidget {
  const SignInWithFacebook({
    super.key,
    required this.logInOrSignIn,
    required this.onTap,
  });

  final String logInOrSignIn;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Image.asset(
          "assets/Image/facebook_icon.png",
          width: 30, // Smaller size to fit the button
          height: 24,
        ),
        label: Text(
          '$logInOrSignIn with Facebook',
          style: KTextStyle,
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.grey[100], // Match the "Sign Up" button
        ),
      ),
    );
  }
}
