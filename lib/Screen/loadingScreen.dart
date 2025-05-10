import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:farm_wise/service/location.dart';
import 'package:http/http.dart'as http;
import "dart:convert";

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    getLocation(); //get the location once the app starts running
    super.initState();
  }

  void getLocation() async {
    Location location = Location();
    await location.getCurrentLocation();
    print(location.longitude);
    print(location.latitude);
  }
  void getData()async{
    http.Response response = await http.get(
       Uri.parse( "https://api.openweathermap.org/data/2.5/weather?lat=32.5556&lon=35.85&appid=aa82b0bddbd9261224f665479d913946")
    );
   if(response.statusCode==200){
     String data= response.body;
     var longitude= jsonDecode(data)['coord']['lon'];
     var latitude=jsonDecode(data)['coord']['lat'];
     var weatherMain=jsonDecode(data)['weather'][0]['main'];
     var weatherDescription=jsonDecode(data)['weather'][0]['description'];
     var weatherIcon=jsonDecode(data)['weather'][0]['icon'];
     var temp=jsonDecode(data)['main'][0]['icon'];

   }else{
     print(response.statusCode);
   }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
