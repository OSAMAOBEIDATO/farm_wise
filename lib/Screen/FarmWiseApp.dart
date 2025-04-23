import 'package:farm_wise/Screen/CropDetails.dart';
import 'package:farm_wise/Screen/SplashScreen.dart';
import 'package:flutter/material.dart';

class FarmWiseApp extends StatelessWidget {
  static const  String id="FarmWiseApp";
  const FarmWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: "Farm Wise App",
      theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true
      ),
      home:  const SpalshScreen(userId: id,),
    );
  }
}
