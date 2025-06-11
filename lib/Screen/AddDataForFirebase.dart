import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/Common/Constant.dart';

class PopulateDiseasesScreen extends StatelessWidget {
  const PopulateDiseasesScreen({super.key});

  /// Adds sample diseases to the Firestore 'diseases' collection
  Future<void> _populateDiseases(BuildContext context) async {
    final List<Map<String, dynamic>> sampleDiseases =
    [
      {
        "DiseaseName": "Apple___Apple_scab",
        "Cure/Treatment": "Apply fungicides like sulfur or myclobutanil. Prune infected branches.",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Avoid overhead irrigation; use drip irrigation.",
        "Additional Info": "Common in humid climates. Remove fallen leaves to prevent spread."
      },
      {
        "DiseaseName": "Apple___Black_rot",
        "Cure/Treatment": "Apply fungicides like captan. Remove and destroy infected fruit and branches.",
        "Fertilizer Recommendation": "Potassium-rich fertilizer (0-0-50)",
        "Irrigation Guidelines": "Water deeply but infrequently to avoid waterlogging.",
        "Additional Info": "Common in warm, wet weather. Prune for better air circulation."
      },
      {
        "DiseaseName": "Apple___Cedar_apple_rust",
        "Cure/Treatment": "Apply fungicides like triadimefon. Remove nearby juniper plants.",
        "Fertilizer Recommendation": "Calcium-rich fertilizer",
        "Irrigation Guidelines": "Avoid overwatering; ensure proper drainage.",
        "Additional Info": "Requires both apple and juniper plants to complete its life cycle."
      },
      {
        "DiseaseName": "Cherry_(including_sour)___Powdery_mildew",
        "Cure/Treatment": "Apply sulfur or potassium bicarbonate. Prune infected areas.",
        "Fertilizer Recommendation": "Low-nitrogen fertilizer",
        "Irrigation Guidelines": "Water early in the day to allow leaves to dry.",
        "Additional Info": "Thrives in high humidity and moderate temperatures."
      },
      {
        "DiseaseName": "Corn_(maize)___Cercospora_leaf_spot_Gray_leaf_spot",
        "Cure/Treatment": "Apply fungicides like azoxystrobin. Rotate crops.",
        "Fertilizer Recommendation": "Nitrogen-rich fertilizer (30-0-0)",
        "Irrigation Guidelines": "Avoid overhead irrigation; use drip irrigation.",
        "Additional Info": "Common in warm, humid conditions. Remove crop debris after harvest."
      },
      {
        "DiseaseName": "Corn_(maize)___Common_rust_",
        "Cure/Treatment": "Apply fungicides like chlorothalonil. Plant resistant varieties.",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (15-15-15)",
        "Irrigation Guidelines": "Water moderately; avoid water stress.",
        "Additional Info": "Spread by wind. Common in cool, wet weather."
      },
      {
        "DiseaseName": "Corn_(maize)___Northern_Leaf_Blight",
        "Cure/Treatment": "Apply fungicides like mancozeb. Rotate crops and remove debris.",
        "Fertilizer Recommendation": "Phosphorus-rich fertilizer (0-20-0)",
        "Irrigation Guidelines": "Avoid overwatering; ensure proper drainage.",
        "Additional Info": "Thrives in wet, humid conditions. Plant resistant varieties."
      },
      {
        "DiseaseName": "Grape___Black_rot",
        "Cure/Treatment": "Apply fungicides like mancozeb. Remove infected fruit and leaves.",
        "Fertilizer Recommendation": "Potassium-rich fertilizer (0-0-50)",
        "Irrigation Guidelines": "Water deeply but infrequently to avoid waterlogging.",
        "Additional Info": "Common in warm, wet weather. Prune for better air circulation."
      },
      {
        "DiseaseName": "Grape___Esca_(Black_Measles)",
        "Cure/Treatment": "Prune infected wood and apply fungicides like thiophanate-methyl.",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Avoid overwatering; ensure proper drainage.",
        "Additional Info": "A fungal disease that affects older vines."
      },
      {
        "DiseaseName": "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",
        "Cure/Treatment": "Apply fungicides like copper-based sprays. Remove infected leaves.",
        "Fertilizer Recommendation": "Calcium-rich fertilizer",
        "Irrigation Guidelines": "Water early in the day to allow leaves to dry.",
        "Additional Info": "Common in warm, humid climates."
      },
      {
        "DiseaseName": "Orange___Haunglongbing_(Citrus_greening)",
        "Cure/Treatment": "Remove infected trees. Control psyllid insects with insecticides.",
        "Fertilizer Recommendation": "Citrus-specific fertilizer (8-3-9)",
        "Irrigation Guidelines": "Water regularly; avoid water stress.",
        "Additional Info": "Caused by bacteria spread by psyllid insects. No cure once infected."
      },
      {
        "DiseaseName": "Peach___Bacterial_spot",
        "Cure/Treatment": "Apply copper-based sprays. Prune infected branches.",
        "Fertilizer Recommendation": "Low-nitrogen fertilizer",
        "Irrigation Guidelines": "Avoid overhead irrigation; use drip irrigation.",
        "Additional Info": "Common in warm, wet weather. Plant resistant varieties."
      },
      {
        "DiseaseName": "Pepper,_bell___Bacterial_spot",
        "Cure/Treatment": "Apply copper-based sprays. Remove infected plants.",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water early in the day to allow leaves to dry.",
        "Additional Info": "Spread by rain, wind, and contaminated tools."
      },
      {
        "DiseaseName": "Pepper,_bell___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water regularly; avoid water stress.",
        "Additional Info": "Healthy plants require proper care and monitoring."
      },
      {
        "DiseaseName": "Potato___Early_blight",
        "Cure/Treatment": "Apply fungicides like chlorothalonil. Rotate crops.",
        "Fertilizer Recommendation": "Potassium-rich fertilizer (0-0-50)",
        "Irrigation Guidelines": "Avoid overhead irrigation; use drip irrigation.",
        "Additional Info": "Common in warm, humid conditions. Remove infected leaves."
      },
      {
        "DiseaseName": "Potato___Late_blight",
        "Cure/Treatment": "Apply fungicides like mancozeb. Remove and destroy infected plants.",
        "Fertilizer Recommendation": "Phosphorus-rich fertilizer (0-20-0)",
        "Irrigation Guidelines": "Avoid overwatering; ensure proper drainage.",
        "Additional Info": "Caused by the same pathogen as the Irish Potato Famine."
      },
      {
        "DiseaseName": "Squash___Powdery_mildew",
        "Cure/Treatment": "Apply sulfur or potassium bicarbonate. Prune infected areas.",
        "Fertilizer Recommendation": "Low-nitrogen fertilizer",
        "Irrigation Guidelines": "Water early in the day to allow leaves to dry.",
        "Additional Info": "Thrives in high humidity and moderate temperatures."
      },
      {
        "DiseaseName": "Strawberry___Leaf_scorch",
        "Cure/Treatment": "Apply fungicides like thiophanate-methyl. Remove infected leaves.",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Avoid overhead irrigation; use drip irrigation.",
        "Additional Info": "Common in warm, humid conditions. Plant resistant varieties."
      },
      {
        "DiseaseName": "Tomato___Bacterial_spot",
        "Cure/Treatment": "Apply copper-based sprays. Remove infected plants.",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water early in the day to allow leaves to dry.",
        "Additional Info": "Spread by rain, wind, and contaminated tools."
      },
      {
        "DiseaseName": "Tomato___Early_blight",
        "Cure/Treatment": "Apply fungicides like chlorothalonil. Rotate crops.",
        "Fertilizer Recommendation": "Potassium-rich fertilizer (0-0-50)",
        "Irrigation Guidelines": "Avoid overhead irrigation; use drip irrigation.",
        "Additional Info": "Common in warm, humid conditions. Remove infected leaves."
      },
      {
        "DiseaseName": "Tomato___Late_blight",
        "Cure/Treatment": "Apply fungicides like mancozeb. Remove and destroy infected plants.",
        "Fertilizer Recommendation": "Phosphorus-rich fertilizer (0-20-0)",
        "Irrigation Guidelines": "Avoid overwatering; ensure proper drainage.",
        "Additional Info": "Caused by the same pathogen as the Irish Potato Famine."
      },
      {
        "DiseaseName": "Tomato___Leaf_Mold",
        "Cure/Treatment": "Apply fungicides like chlorothalonil. Prune for better air circulation.",
        "Fertilizer Recommendation": "Calcium-rich fertilizer",
        "Irrigation Guidelines": "Avoid overhead irrigation; use drip irrigation.",
        "Additional Info": "Thrives in high humidity and poor air circulation."
      },
      {
        "DiseaseName": "Tomato___Septoria_leaf_spot",
        "Cure/Treatment": "Apply fungicides like mancozeb. Remove infected leaves.",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Avoid overhead irrigation; use drip irrigation.",
        "Additional Info": "Common in warm, wet weather. Remove crop debris after harvest."
      },
      {
        "DiseaseName": "Tomato___Spider_mites_Two-spotted_spider_mite",
        "Cure/Treatment": "Apply miticides like neem oil. Increase humidity.",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water regularly; avoid water stress.",
        "Additional Info": "Thrives in dry, hot conditions. Keep plants well-watered."
      },
      {
        "DiseaseName": "Tomato___Target_Spot",
        "Cure/Treatment": "Apply fungicides like chlorothalonil. Remove infected leaves.",
        "Fertilizer Recommendation": "Potassium-rich fertilizer (0-0-50)",
        "Irrigation Guidelines": "Avoid overhead irrigation; use drip irrigation.",
        "Additional Info": "Common in warm, humid conditions. Plant resistant varieties."
      },
      {
        "DiseaseName": "Tomato___Tomato_Yellow_Leaf_Curl_Virus",
        "Cure/Treatment": "Control whiteflies with insecticides. Remove infected plants.",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water regularly; avoid water stress.",
        "Additional Info": "Spread by whiteflies. No cure once infected."
      },
      {
        "DiseaseName": "Tomato___Tomato_mosaic_virus",
        "Cure/Treatment": "Remove infected plants. Control aphids with insecticides.",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water regularly; avoid water stress.",
        "Additional Info": "Spread by aphids and contaminated tools. No cure once infected."
      },
      {
        "DiseaseName": "Cherry_(including_sour)___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water regularly but avoid waterlogging.",
        "Additional Info": "Healthy trees require full sun and well-drained soil."
      },
      {
        "DiseaseName": "Corn_(maize)___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Nitrogen-rich fertilizer (30-0-0)",
        "Irrigation Guidelines": "Water moderately during growing season.",
        "Additional Info": "Ensure adequate sunlight and spacing for air circulation."
      },
      {
        "DiseaseName": "Grape___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water deeply; avoid wetting the leaves.",
        "Additional Info": "Healthy vines benefit from annual pruning."
      },
      {
        "DiseaseName": "Peach___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Low-nitrogen fertilizer",
        "Irrigation Guidelines": "Water regularly; mulch to retain moisture.",
        "Additional Info": "Good airflow and sun exposure are important."
      },
      {
        "DiseaseName": "Potato___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Potassium-rich fertilizer (0-0-50)",
        "Irrigation Guidelines": "Keep soil evenly moist, not soggy.",
        "Additional Info": "Rotate crops to maintain soil health."
      },
      {
        "DiseaseName": "Raspberry___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water regularly; avoid overhead watering.",
        "Additional Info": "Proper pruning improves yield and health."
      },
      {
        "DiseaseName": "Soybean___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Inoculated with rhizobia; use phosphorus-rich fertilizer if needed.",
        "Irrigation Guidelines": "Maintain consistent moisture during flowering.",
        "Additional Info": "Healthy soybeans fix nitrogen naturally."
      },
      {
        "DiseaseName": "Strawberry___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Drip irrigation preferred to keep leaves dry.",
        "Additional Info": "Regular weeding and mulching help prevent disease."
      },
      {
        "DiseaseName": "Tomato___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water at base; avoid wetting leaves.",
        "Additional Info": "Staking and pruning improve growth and airflow."
      },
      {
        "DiseaseName": "Blueberry___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Acid-loving plant fertilizer (e.g., 12-4-8)",
        "Irrigation Guidelines": "Keep soil moist and acidic (pH 4.5–5.5).",
        "Additional Info": "Mulch with pine needles or bark to maintain acidity."
      },


      {
        "DiseaseName": "Cherry_(including_sour)___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water regularly but avoid waterlogging.",
        "Additional Info": "Healthy trees require full sun and well-drained soil."
      },
      {
        "DiseaseName": "Corn_(maize)___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Nitrogen-rich fertilizer (30-0-0)",
        "Irrigation Guidelines": "Water moderately during growing season.",
        "Additional Info": "Ensure adequate sunlight and spacing for air circulation."
      },
      {
        "DiseaseName": "Grape___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water deeply; avoid wetting the leaves.",
        "Additional Info": "Healthy vines benefit from annual pruning."
      },
      {
        "DiseaseName": "Peach___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Low-nitrogen fertilizer",
        "Irrigation Guidelines": "Water regularly; mulch to retain moisture.",
        "Additional Info": "Good airflow and sun exposure are important."
      },
      {
        "DiseaseName": "Potato___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Potassium-rich fertilizer (0-0-50)",
        "Irrigation Guidelines": "Keep soil evenly moist, not soggy.",
        "Additional Info": "Rotate crops to maintain soil health."
      },
      {
        "DiseaseName": "Raspberry___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water regularly; avoid overhead watering.",
        "Additional Info": "Proper pruning improves yield and health."
      },
      {
        "DiseaseName": "Soybean___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Inoculated with rhizobia; use phosphorus-rich fertilizer if needed.",
        "Irrigation Guidelines": "Maintain consistent moisture during flowering.",
        "Additional Info": "Healthy soybeans fix nitrogen naturally."
      },
      {
        "DiseaseName": "Strawberry___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Drip irrigation preferred to keep leaves dry.",
        "Additional Info": "Regular weeding and mulching help prevent disease."
      },
      {
        "DiseaseName": "Tomato___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Balanced NPK fertilizer (10-10-10)",
        "Irrigation Guidelines": "Water at base; avoid wetting leaves.",
        "Additional Info": "Staking and pruning improve growth and airflow."
      },
      {
        "DiseaseName": "Blueberry___healthy",
        "Cure/Treatment": "N/A",
        "Fertilizer Recommendation": "Acid-loving plant fertilizer (e.g., 12-4-8)",
        "Irrigation Guidelines": "Keep soil moist and acidic (pH 4.5–5.5).",
        "Additional Info": "Mulch with pine needles or bark to maintain acidity."
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