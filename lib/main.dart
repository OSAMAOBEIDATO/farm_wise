import 'package:farm_wise/service/AuthCheck.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( const FarmWiseApp());

}

class FarmWiseApp extends StatelessWidget {
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
      home:  const AuthWrapper(),
    );
  }
}

