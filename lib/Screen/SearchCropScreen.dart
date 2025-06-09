import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/Components/SearchScreenComponent/CropCardSearchScreen.dart';
import 'package:farm_wise/Components/SearchScreenComponent/DateSelectionSection.dart';
import 'package:farm_wise/Components/SearchScreenComponent/EmptyStateForSearch.dart';
import 'package:farm_wise/Components/SearchScreenComponent/ErrorCardSearchScreen.dart';
import 'package:farm_wise/Components/SearchScreenComponent/HeaderForSearchScreen.dart';
import 'package:farm_wise/Components/SearchScreenComponent/SaveButton.dart';
import 'package:farm_wise/Components/SearchScreenComponent/SearchBar.dart';
import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:farm_wise/components/SnakBar.dart';
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
            int harvestDays = crop['harvestDate'] ?? 0;
            harvestDateTime = plantDateTime.add(Duration(days: harvestDays));
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
            'PlantDate': plantDateTime != null
                ? Timestamp.fromDate(plantDateTime)
                : null,
            'HarvestDate': harvestDateTime != null
                ? Timestamp.fromDate(harvestDateTime)
                : null,
            'fertilizers': crop['fertilizers'] ?? [],
            'type': crop['type'],
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
        message +=
            "${successfullyAddedCrops.length} crop(s) added successfully: ${successfullyAddedCrops.join(', ')}.";
      }
      if (failedCrops.isNotEmpty) {
        message +=
            "\nFailed to add ${failedCrops.length} crop(s): ${failedCrops.join(', ')}.";
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

  Future<void> _refreshData() async {
    await _waitForAuthAndFetchCrops();
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    return CropCardSearchScreen(
      crop: crop,
      selectedCropIds: _selectedCropIds,
      existingCropNames: _existingCropNames,
      onTap: () {
        setState(() {
          if (_selectedCropIds.contains(crop['id'])) {
            _selectedCropIds.remove(crop['id']);
          } else {
            _selectedCropIds.add(crop['id']);
          }
        });
      },
    );
  }

  Widget _buildDateSelectionSection() {
    return DateSelectionSection(
      selectedCropIds: _selectedCropIds,
      availableCrops: _availableCrops,
      plantDateControllers: _plantDateControllers,
      onDateSelected: _selectDate,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Add New Crops",
          style: GoogleFonts.adamina(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isFetchingCrops
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.green,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderForSearchScreen(refreshData: _refreshData),
                    const SizedBox(height: 24),
                    SearchBarForSearchScreen(
                        searchController: _searchController),
                    const SizedBox(height: 24),
                    if (fetchError != null)
                      ErrorCardSearchScreen(
                          fetchError: fetchError, refreshData: _refreshData)
                    else if (_searchController.text.isEmpty)
                      const EmptyStateForSearch()
                    else if (_filteredCrops.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.agriculture,
                                color: Colors.green[600], size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Available Crops',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '${_filteredCrops.length} found',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredCrops.length,
                        itemBuilder: (context, index) {
                          return _buildCropCard(_filteredCrops[index]);
                        },
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No crops found',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try searching with different keywords',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_selectedCropIds.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildDateSelectionSection(),
                      const SizedBox(height: 24),
                      SaveButton(
                        isLoading: isLoading,
                        selectedCount: _selectedCropIds.length,
                        onPressed: _saveSelectedCrops,
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
