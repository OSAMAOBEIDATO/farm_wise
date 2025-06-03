import 'package:farm_wise/Common/Constant.dart';
import 'package:flutter/material.dart';

class CustomSnackBar {
  void ShowSnackBar({
    required BuildContext context,
    required String text,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
            text,
            style: KTextStyle,
          ),
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10)),
    );
  }
}