import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/Common/Constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchCropScreen extends StatefulWidget {
  const SearchCropScreen({super.key});

  @override
  State<SearchCropScreen> createState() => _SearchCropScreenState();
}

class _SearchCropScreenState extends State<SearchCropScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, TextEditingController> _plantDateControllers = {};
  List<Map<String, dynamic>> _availableCrops = [];
  List<Map<String, dynamic>> _filteredCrops = [];
  final Set<String> _selectedCropIds = {};
  List<String> _existingCropNames = [];

  bool isLoading = false;
  bool isFetchingCrops = true;
  String? fetchError;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _waitForAuthAndFetchCrops();
    _searchController.addListener(_filterCrops);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _plantDateControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _waitForAuthAndFetchCrops() async {
    setState(() {
      isFetchingCrops = true;
      fetchError = null;
    });

    try {
      _userId = FirebaseAuth.instance.currentUser?.uid;
      if (_userId == null) {
        throw Exception('No user is currently authenticated');
      }
      QuerySnapshot userCropsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('crops')
          .get();
      _existingCropNames = userCropsSnapshot.docs
          .map((doc) =>
          ((doc.data() as Map<String, dynamic>)['CropName'] as String)
              .toLowerCase())
          .toList();

      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('crops').get();
      _availableCrops = snapshot.docs.map((doc) {
        final crop = doc.data() as Map<String, dynamic>;
        crop['id'] = doc.id;
        _plantDateControllers[doc.id] = TextEditingController();
        return crop;
      }).toList();

      setState(() {
        _filteredCrops = [];
        isFetchingCrops = false;
      });
    } catch (e) {
      setState(() {
        isFetchingCrops = false;
        fetchError = e.toString();
      });
      if (e.toString().contains('No user is currently authenticated')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        });
      }
    }
  }

  void _filterCrops() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCrops = _availableCrops
          .where((crop) => crop['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _selectDate(String cropId) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      barrierColor: Colors.green,
    );

    if (picked != null) {
      _plantDateControllers[cropId]?.text =
      "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> _saveSelectedCrops() async {
    if (_selectedCropIds.isEmpty) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: "Please select at least one crop",
      );
      return;
    }

    List<String> cropsWithoutDates = [];
    for (String cropId in _selectedCropIds) {
      final date = _plantDateControllers[cropId]?.text ?? "";
      if (date.isEmpty) {
        final crop = _availableCrops.firstWhere((c) => c['id'] == cropId);
        cropsWithoutDates.add(crop['name']);
      }
    }
    if (cropsWithoutDates.isNotEmpty) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: "Please set planting dates for: ${cropsWithoutDates.join(', ')}",
      );
      return;
    }

    if (_userId == null) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: "Error: User not authenticated",
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      List<String> successfullyAddedCrops = [];
      List<String> failedCrops = [];

      for (String cropId in _selectedCropIds) {
        try {
          final crop = _availableCrops.firstWhere((c) => c['id'] == cropId);
          final date = _plantDateControllers[cropId]?.text ?? "";

          DateTime? plantDateTime;
          DateTime? harvestDateTime;
          if (date.isNotEmpty) {
            List<String> dateParts = date.split('/');
            plantDateTime = DateTime(
              int.parse(dateParts[2]),
              int.parse(dateParts[1]),
              int.parse(dateParts[0]),
            );
            int harvestDays = crop['harvestDate'] ??0 ;
            harvestDateTime =
                plantDateTime.add(Duration(days: harvestDays));
          }

          if (_existingCropNames.contains(crop['name'].toLowerCase())) {
            failedCrops.add("${crop['name']} (already in your crops)");
            continue;
          }



          final docRef = await FirebaseFirestore.instance
              .collection("users")
              .doc(_userId)
              .collection("crops")
              .add({
            'CropID': '',
            'UserID': _userId,
            'CropName': crop['name'],
            'PlantDate': plantDateTime != null ? Timestamp.fromDate(plantDateTime) : null,
            'HarvestDate': harvestDateTime != null ? Timestamp.fromDate(harvestDateTime) : null,
            'fertilizers': crop['fertilizers'] ?? [],
            'createdAt': FieldValue.serverTimestamp(),
          });
          await docRef.update({'CropID': docRef.id});
          successfullyAddedCrops.add(crop['name']);
          _existingCropNames.add(crop['name'].toLowerCase());
        } catch (e) {
          final crop = _availableCrops.firstWhere((c) => c['id'] == cropId);
          failedCrops.add("${crop['name']} (error: $e)");
        }
      }

      String message = '';
      if (successfullyAddedCrops.isNotEmpty) {
        message += "${successfullyAddedCrops.length} crop(s) added successfully: ${successfullyAddedCrops.join(', ')}.";
      }
      if (failedCrops.isNotEmpty) {
        message += "\nFailed to add ${failedCrops.length} crop(s): ${failedCrops.join(', ')}.";
      }

      CustomSnackBar().ShowSnackBar(
        context: context,
        text: message,
      );

      if (successfullyAddedCrops.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
        );
      }
    } catch (e) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: "Unexpected error: $e",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Crops",
          style: GoogleFonts.adamina(fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.green,
      ),
      body: isFetchingCrops
          ? const Center(
        child: CircularProgressIndicator(color: Colors.green),
      )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              iconColor: Colors.black,
              focusColor: Colors.green,
              hintText: "Search crops...",
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          _filteredCrops.isEmpty
              ? const Text("Search to view crops")
              : Expanded(
            child: ListView.builder(
              itemCount: _filteredCrops.length,
              itemBuilder: (context, index) {
                final crop = _filteredCrops[index];
                final selected = _selectedCropIds.contains(crop['id']);
                final isAlreadyAdded =
                _existingCropNames.contains(crop['name'].toLowerCase());

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: selected
                      ? Colors.green[50]
                      : (isAlreadyAdded ? Colors.grey[200] : null),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(crop['name']),
                    subtitle: Text("Type: ${crop['type']}"),
                    trailing: selected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : (isAlreadyAdded
                        ? const Icon(Icons.lock, color: Colors.grey)
                        : null),
                    onTap: isAlreadyAdded
                        ? () {
                      CustomSnackBar().ShowSnackBar(
                        context: context,
                        text: "${crop['name']} is already in your crops!",
                      );
                    }
                        : () {
                      setState(() {
                        if (selected) {
                          _selectedCropIds.remove(crop['id']);
                        } else {
                          _selectedCropIds.add(crop['id']);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          if (_selectedCropIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text("Set Planting Dates:", style: KTextStyle),
            const SizedBox(height: 8),
            Column(
              children: _selectedCropIds.map((cropId) {
                final controller = _plantDateControllers[cropId]!;
                final crop =
                _availableCrops.firstWhere((c) => c['id'] == cropId);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          crop['name'],
                          style: KTextStyle,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.black),
                          readOnly: true,
                          decoration: const InputDecoration(
                            hintText: "Select Date",
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                            suffixIcon: Icon(Icons.calendar_today,color:Colors.black,),
                            iconColor: Colors.green,
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                          onTap: () => _selectDate(cropId),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _saveSelectedCrops,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : Text("Save Selected Crops (${_selectedCropIds.length})",
                  style: KTextStyle),
            ),
          ],
        ],
      ),
    );
  }
}