import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/Common/Constant.dart';

class PopulateCropsScreen extends StatelessWidget {
  const PopulateCropsScreen({super.key});

  /// Adds sample crops to the Firestore 'crops' collection
  Future<void> _populateCrops(BuildContext context) async {
    final List<Map<String, dynamic>> sampleCrops = [
      {
        'name': 'Apple',
        'type': 'Fruit',
        'growingTime': 150,
        'harvestDate': 180,
        'soilType': 'Loamy',
        'fertilizers': 'Nitrogen-rich',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '25 mm/week',
        'irrigationGuide': 'Deep water every 7–10 days; increase during fruit development.',
      },
      {
        'name': 'Blueberry',
        'type': 'Fruit',
        'growingTime': 60,
        'harvestDate': 90,
        'soilType': 'Acidic',
        'fertilizers': 'Compost',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '20 mm/week',
        'irrigationGuide': 'Drip irrigation 2–3 times per week; keep soil consistently moist.',
      },
      {
        'name': 'Cherry',
        'type': 'Fruit',
        'growingTime': 140,
        'harvestDate': 160,
        'soilType': 'Loamy',
        'fertilizers': 'Balanced NPK',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '30 mm/week',
        'irrigationGuide': 'Irrigate every 7 days ensure soil has good drainage.',
      },
      {
        'name': 'Corn',
        'type': 'Grain',
        'growingTime': 90,
        'harvestDate': 100,
        'soilType': 'Loamy',
        'fertilizers': 'Nitrogen-rich',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '25 mm/week',
        'irrigationGuide': 'Water every 3–5 days during tasseling and ear development.',
      },
      {
        'name': 'Grape',
        'type': 'Fruit',
        'growingTime': 180,
        'harvestDate': 200,
        'soilType': 'Sandy-Loam',
        'fertilizers': 'Organic Compost',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '20 mm/week',
        'irrigationGuide': 'Weekly drip irrigation; reduce watering before harvest for sweeter fruit.',
      },
      {
        'name': 'Orange',
        'type': 'Fruit',
        'growingTime': 270,
        'harvestDate': 300,
        'soilType': 'Sandy-Loam',
        'fertilizers': 'Citrus Fertilizer',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '35 mm/week',
        'irrigationGuide': 'Water deeply every 10–14 days; supplement with light irrigation in dry spells.',
      },
      {
        'name': 'Peach',
        'type': 'Fruit',
        'growingTime': 120,
        'harvestDate': 140,
        'soilType': 'Loamy',
        'fertilizers': 'Potassium-rich',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '30 mm/week',
        'irrigationGuide': 'Irrigate every 7–10 days; increase to twice weekly during fruit enlargement.',
      },
      {
        'name': 'Pepper',
        'type': 'Vegetable',
        'growingTime': 70,
        'harvestDate': 80,
        'soilType': 'Well-drained',
        'fertilizers': 'Phosphorus-rich',
        'bestPlantingSeason': 'Late Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '25 mm/week',
        'irrigationGuide': 'Deep watering 2 times per week; maintain even moisture, especially when fruiting.',
      },
      {
        'name': 'Potato',
        'type': 'Vegetable',
        'growingTime': 90,
        'harvestDate': 100,
        'soilType': 'Sandy',
        'fertilizers': 'Balanced NPK',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '30 mm/week',
        'irrigationGuide': 'Maintain even moisture; water every 4–6 days during tuber formation.',
      },
      {
        'name': 'Raspberry',
        'type': 'Fruit',
        'growingTime': 75,
        'harvestDate': 90,
        'soilType': 'Loamy',
        'fertilizers': 'Organic Mulch',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '25 mm/week',
        'irrigationGuide': 'Drip irrigation 3 times per week; keep soil moist but not waterlogged.',
      },
      {
        'name': 'Soybean',
        'type': 'Grain',
        'growingTime': 100,
        'harvestDate': 110,
        'soilType': 'Well-drained',
        'fertilizers': 'Nitrogen-fixing',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '20 mm/week',
        'irrigationGuide': 'Water every 5–7 days; increase to every 3 days during flowering and pod fill.',
      },
      {
        'name': 'Squash',
        'type': 'Vegetable',
        'growingTime': 85,
        'harvestDate': 95,
        'soilType': 'Loamy',
        'fertilizers': 'Compost',
        'bestPlantingSeason': 'Late Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '25 mm/week',
        'irrigationGuide': 'Shallow, frequent watering every 2–3 days; avoid overhead watering to reduce disease.',
      },
      {
        'name': 'Strawberry',
        'type': 'Fruit',
        'growingTime': 60,
        'harvestDate': 75,
        'soilType': 'Sandy Loam',
        'fertilizers': 'Phosphorus-rich',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '20 mm/week',
        'irrigationGuide': 'Daily drip irrigation during flowering and fruiting; reduce to every 2 days after harvest.',
      },
      {
        'name': 'Tomato',
        'type': 'Vegetable',
        'growingTime': 85,
        'harvestDate': 100,
        'soilType': 'Loamy',
        'fertilizers': 'Nitrogen-rich',
        'bestPlantingSeason': 'Spring',
        'sunlight': 'Full Sun',
        'waterRequirement': '30 mm/week',
        'irrigationGuide': 'Deep watering 2–3 times a week; water at the base and avoid wetting foliage.',
      },
    ];

    try {
      for (var crop in sampleCrops) {
        await FirebaseFirestore.instance.collection('crops').add(crop);
      }
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Crops added successfully!',
      );
    } catch (e) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Error adding crops: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Populate Crops',
          style: GoogleFonts.adamina(
            fontSize: 25,
            color: Colors.green[700],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add Sample Crops to Firestore',
                style: GoogleFonts.adamina(
                  fontSize: 30,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _populateCrops(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.grey[100],
                  ),
                  child: Text('Add Crops', style: KTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}