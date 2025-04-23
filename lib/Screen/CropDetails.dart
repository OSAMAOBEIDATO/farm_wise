import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:flutter/material.dart';

class CropDetails extends StatefulWidget {
  const CropDetails({super.key});

  @override
  State<CropDetails> createState() => _CropDetailsState();
}

class _CropDetailsState extends State<CropDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(),
                ),
              );
            },
            icon: Icon(Icons.arrow_back_outlined))
      ]),
      body: Center(
        child: Text('data'),
      ),
    );
  }
}
