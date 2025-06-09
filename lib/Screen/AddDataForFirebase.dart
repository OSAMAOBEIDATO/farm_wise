import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/Common/Constant.dart';

class PopulateDiseasesScreen extends StatelessWidget {
  const PopulateDiseasesScreen({super.key});

  /// Adds sample diseases to the Firestore 'diseases' collection
  Future<void> _populateDiseases(BuildContext context) async {
    final List<Map<String, dynamic>> sampleDiseases = [
      {
        'diseaseName': 'Apple___Apple_scab',
        'cureTreatment': 'Apply fungicides like sulfur or myclobutanil. Prune infected branches.',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (10-10-10)',
        'irrigationGuidelines': 'Avoid overhead irrigation; use drip irrigation.',
        'additionalInfo': 'Common in humid climates. Remove fallen leaves to prevent spread.'
      },
      {
        'diseaseName': 'Apple___Black_rot',
        'cureTreatment': 'Apply fungicides like captan. Remove and destroy infected fruit and branches.',
        'fertilizerRecommendation': 'Potassium-rich fertilizer (0-0-50)',
        'irrigationGuidelines': 'Water deeply but infrequently to avoid waterlogging.',
        'additionalInfo': 'Common in warm, wet weather. Prune for better air circulation.'
      },
      {
        'diseaseName': 'Apple___Cedar_apple_rust',
        'cureTreatment': 'Apply fungicides like triadimefon. Remove nearby juniper plants.',
        'fertilizerRecommendation': 'Calcium-rich fertilizer',
        'irrigationGuidelines': 'Avoid overwatering; ensure proper drainage.',
        'additionalInfo': 'Requires both apple and juniper plants to complete its life cycle.'
      },
      {
        'diseaseName': 'Cherry_(including_sour)___Powdery_mildew',
        'cureTreatment': 'Apply sulfur or potassium bicarbonate. Prune infected areas.',
        'fertilizerRecommendation': 'Low-nitrogen fertilizer',
        'irrigationGuidelines': 'Water early in the day to allow leaves to dry.',
        'additionalInfo': 'Thrives in high humidity and moderate temperatures.'
      },
      {
        'diseaseName': 'Corn_(maize)___Cercospora_leaf_spot_Gray_leaf_spot',
        'cureTreatment': 'Apply fungicides like azoxystrobin. Rotate crops.',
        'fertilizerRecommendation': 'Nitrogen-rich fertilizer (30-0-0)',
        'irrigationGuidelines': 'Avoid overhead irrigation; use drip irrigation.',
        'additionalInfo': 'Common in warm, humid conditions. Remove crop debris after harvest.'
      },
      {
        'diseaseName': 'Corn_(maize)___Common_rust_',
        'cureTreatment': 'Apply fungicides like chlorothalonil. Plant resistant varieties.',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (15-15-15)',
        'irrigationGuidelines': 'Water moderately; avoid water stress.',
        'additionalInfo': 'Spread by wind. Common in cool, wet weather.'
      },
      {
        'diseaseName': 'Corn_(maize)___Northern_Leaf_Blight',
        'cureTreatment': 'Apply fungicides like mancozeb. Rotate crops and remove debris.',
        'fertilizerRecommendation': 'Phosphorus-rich fertilizer (0-20-0)',
        'irrigationGuidelines': 'Avoid overwatering; ensure proper drainage.',
        'additionalInfo': 'Thrives in wet, humid conditions. Plant resistant varieties.'
      },
      {
        'diseaseName': 'Grape___Black_rot',
        'cureTreatment': 'Apply fungicides like mancozeb. Remove infected fruit and leaves.',
        'fertilizerRecommendation': 'Potassium-rich fertilizer (0-0-50)',
        'irrigationGuidelines': 'Water deeply but infrequently to avoid waterlogging.',
        'additionalInfo': 'Common in warm, wet weather. Prune for better air circulation.'
      },
      {
        'diseaseName': 'Grape___Esca_(Black_Measles)',
        'cureTreatment': 'Prune infected wood and apply fungicides like thiophanate-methyl.',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (10-10-10)',
        'irrigationGuidelines': 'Avoid overwatering; ensure proper drainage.',
        'additionalInfo': 'A fungal disease that affects older vines.'
      },
      {
        'diseaseName': 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
        'cureTreatment': 'Apply fungicides like copper-based sprays. Remove infected leaves.',
        'fertilizerRecommendation': 'Calcium-rich fertilizer',
        'irrigationGuidelines': 'Water early in the day to allow leaves to dry.',
        'additionalInfo': 'Common in warm, humid climates.'
      },
      {
        'diseaseName': 'Orange___Haunglongbing_(Citrus_greening)',
        'cureTreatment': 'Remove infected trees. Control psyllid insects with insecticides.',
        'fertilizerRecommendation': 'Citrus-specific fertilizer (8-3-9)',
        'irrigationGuidelines': 'Water regularly; avoid water stress.',
        'additionalInfo': 'Caused by bacteria spread by psyllid insects. No cure once infected.'
      },
      {
        'diseaseName': 'Peach___Bacterial_spot',
        'cureTreatment': 'Apply copper-based sprays. Prune infected branches.',
        'fertilizerRecommendation': 'Low-nitrogen fertilizer',
        'irrigationGuidelines': 'Avoid overhead irrigation; use drip irrigation.',
        'additionalInfo': 'Common in warm, wet weather. Plant resistant varieties.'
      },
      {
        'diseaseName': 'PepPepper,_bell___Bacterial_spot',
        'cureTreatment' : 'Apply copper-based sprays. Remove infected plants.',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (10-10-10)',
        'irrigationGuidelines': 'Water early in the day to allow leaves to dry.',
        'additionalInfo': 'Spread by rain, wind, and contaminated tools.'
      },
      {
        'diseaseName': 'Pepper,_bell___healthy',
        'cureTreatment': 'N/A',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (10-10-10)',
        'irrigationGuidelines': 'Water regularly; avoid water stress.',
        'additionalInfo': 'Healthy plants require proper care and monitoring.'
      },
      {
        'diseaseName': 'Potato___Early_blight',
        'cureTreatment': 'Apply fungicides like chlorothalonil. Rotate crops.',
        'fertilizerRecommendation': 'Potassium-rich fertilizer (0-0-50)',
        'irrigationGuidelines': 'Avoid overhead irrigation; use drip irrigation.',
        'additionalInfo': 'Common in warm, humid conditions. Remove infected leaves.'
      },
      {
        'diseaseName': 'Potato___Late_blight',
        'cureTreatment': 'Apply fungicides like mancozeb. Remove and destroy infected plants.',
        'fertilizerRecommendation': 'Phosphorus-rich fertilizer (0-20-0)',
        'irrigationGuidelines': 'Avoid overwatering; ensure proper drainage.',
        'additionalInfo': 'Caused by the same pathogen as the Irish Potato Famine.'
      },
      {
        'diseaseName': 'Squash___Powdery_mildew',
        'cureTreatment': 'Apply sulfur or potassium bicarbonate. Prune infected areas.',
        'fertilizerRecommendation': 'Low-nitrogen fertilizer',
        'irrigationGuidelines': 'Water early in the day to allow leaves to dry.',
        'additionalInfo': 'Thrives in high humidity and moderate temperatures.'
      },
      {
        'diseaseName': 'Strawberry___Leaf_scorch',
        'cureTreatment': 'Apply fungicides like thiophanate-methyl. Remove infected leaves.',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (10-10-10)',
        'irrigationGuidelines': 'Avoid overhead irrigation; use drip irrigation.',
        'additionalInfo': 'Common in warm, humid conditions. Plant resistant varieties.'
      },
      {
        'diseaseName': 'Tomato___Bacterial_spot',
        'cureTreatment': 'Apply copper-based sprays. Remove infected plants.',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (10-10-10)',
        'irrigationGuidelines': 'Water early in the day to allow leaves to dry.',
        'additionalInfo': 'Spread by rain, wind, and contaminated tools.'
      },
      {
        'diseaseName': 'Tomato___Early_blight',
        'cureTreatment': 'Apply fungicides like chlorothalonil. Rotate crops.',
        'fertilizerRecommendation': 'Potassium-rich fertilizer (0-0-50)',
        'irrigationGuidelines': 'Avoid overhead irrigation; use drip irrigation.',
        'additionalInfo': 'Common in warm, humid conditions. Remove infected leaves.'
      },
      {
        'diseaseName': 'Tomato___Late_blight',
        'cureTreatment': 'Apply fungicides like mancozeb. Remove and destroy infected plants.',
        'fertilizerRecommendation': 'Phosphorus-rich fertilizer (0-20-0)',
        'irrigationGuidelines': 'Avoid overwatering; ensure proper drainage.',
        'additionalInfo': 'Caused by the same pathogen as the Irish Potato Famine.'
      },
      {
        'diseaseName': 'Tomato___Leaf_Mold',
        'cureTreatment': 'Apply fungicides like chlorothalonil. Prune for better air circulation.',
        'fertilizerRecommendation': 'Calcium-rich fertilizer',
        'irrigationGuidelines': 'Avoid overhead irrigation; use drip irrigation.',
        'additionalInfo': 'Thrives in high humidity and poor air circulation.'
      },
      {
        'diseaseName': 'Tomato___Septoria_leaf_spot',
        'cureTreatment': 'Apply fungicides like mancozeb. Remove infected leaves.',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (10-10-10)',
        'irrigationGuidelines': 'Avoid overhead irrigation; use drip irrigation.',
        'additionalInfo': 'Common in warm, wet weather. Remove crop debris after harvest.'
      },
      {
        'diseaseName': 'Tomato___Spider_mites_Two-spotted_spider_mite',
        'cureTreatment': 'Apply miticides like neem oil. Increase humidity.',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (10-10-10)',
        'irrigationGuidelines': 'Water regularly; avoid water stress.',
        'additionalInfo': 'Thrives in dry, hot conditions. Keep plants well-watered.'
      },
      {
        'diseaseName': 'Tomato___Target_Spot',
        'cureTreatment': 'Apply fungicides like chlorothalonil. Remove infected leaves.',
        'fertilizerRecommendation': 'Potassium-rich fertilizer (0-0-50)',
        'irrigationGuidelines': 'Avoid overhead irrigation; use drip irrigation.',
        'additionalInfo': 'Common in warm, humid conditions. Plant resistant varieties.'
      },
      {
        'diseaseName': 'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
        'cureTreatment': 'Control whiteflies with insecticides. Remove infected plants.',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (10-10-10)',
        'irrigationGuidelines': 'Water regularly; avoid water stress.',
        'additionalInfo': 'Spread by whiteflies. No cure once infected.'
      },
      {
        'diseaseName': 'Tomato___Tomato_mosaic_virus',
        'cureTreatment': 'Remove infected plants. Control aphids with insecticides.',
        'fertilizerRecommendation': 'Balanced NPK fertilizer (10-10-10)',
        'irrigationGuidelines': 'Water regularly; avoid water stress.',
        'additionalInfo': 'Spread by aphids and contaminated tools. No cure once infected.'
      }
    ];

    try {
      for (var disease in sampleDiseases) {
        await FirebaseFirestore.instance.collection('diseases').add(disease);
      }
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Diseases added successfully!',
      );
    } catch (e) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Error adding diseases: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Populate Diseases',
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
                'Add Sample Diseases to Firestore',
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
                  onPressed: () => _populateDiseases(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.grey[100],
                  ),
                  child: Text('Add Diseases', style: KTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}