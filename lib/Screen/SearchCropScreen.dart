import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/comman/consta.dart';
import 'package:farm_wise/Screen/HomeScreen.dart';

class SearchCropScreen extends StatefulWidget {
  final String userId;

  const SearchCropScreen({super.key, required this.userId});

  @override
  State<SearchCropScreen> createState() => _SearchCropScreenState();
}

class _SearchCropScreenState extends State<SearchCropScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, TextEditingController> _plantDateControllers = {};

  List<Map<String, dynamic>> _availableCrops = [];
  List<Map<String, dynamic>> _filteredCrops = [];
  Set<String> _selectedCropIds = {}; // To track selected crops

  bool isLoading = false;
  bool isFetchingCrops = true;
  String? fetchError;

  @override
  void initState() {
    super.initState();
    _waitForAuthAndFetchCrops();
    _searchController.addListener(_filterCrops);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _plantDateControllers.forEach(
      (key, controller) => controller.dispose(),
    );
    super.dispose();
  }

  Future<void> _waitForAuthAndFetchCrops() async {
    setState(() {
      isFetchingCrops = true;
      fetchError = null;
    });

    try {
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

    setState(
      () => isLoading = true,
    );

    try {
      for (final cropId in _selectedCropIds) {
        final crop = _availableCrops.firstWhere((c) => c['id'] == cropId);
        final date = _plantDateControllers[cropId]?.text ?? "";

        final docRef = await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userId)
            .collection("crops")
            .add({
          'CropID': '',
          'UserID': widget.userId,
          'CropName': crop['name'],
          'PlantDate': date,
          'HarvestDate': '',
          'PlantType': crop['type'],
          'fertilizers': crop['fertilizers'],
          'pesticides': '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await docRef.update({'CropID': docRef.id});
      }

      CustomSnackBar()
          .ShowSnackBar(context: context, text: "Crops added successfully!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(userId: widget.userId),
        ),
      );
    } catch (e) {
      CustomSnackBar()
          .ShowSnackBar(context: context, text: "Error saving crops: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Crops", style: KTextStyle)),
      body: isFetchingCrops
          ? const Center(child: CircularProgressIndicator())
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
              hintText: "Search crops...",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

                      return Card(
                        elevation: 2,
                        color: selected ? Colors.green[50] : null,
                        child: ListTile(
                          title: Text(crop['name']),
                          subtitle: Text("Type: ${crop['type']}"),
                          trailing: selected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : null,
                          onTap: () {
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
                      Expanded(child: Text(crop['name'])),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          readOnly: true,
                          decoration: const InputDecoration(
                            hintText: "Select Date",
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
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
                  ? const CircularProgressIndicator()
                  : Text("Save Selected Crops", style: KTextStyle),
            ),
          ],
        ],
      ),
    );
  }
}
