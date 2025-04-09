import 'package:farm_wise/Screen/SplashScreen.dart';
import 'package:flutter/cupertino.dart';

import '../Screen/HomeScreen.dart';
import '../Screen/LoginScreen.dart';
import '../Screen/ProfileScreen.dart';
import '../Screen/SignUpScreen.dart';

class AppRouter{
  static String   initialRoute=SpalshScreen.id;
  static Map<String,WidgetBuilder>routes={
    Loginscreen.id:(context)=>Loginscreen(),
    SignUpScreen.id:(context)=>SignUpScreen(),
    ProfileScreen.id:(context)=>ProfileScreen(),
    HomeScreen.id:(context)=>HomeScreen(),

  };
}