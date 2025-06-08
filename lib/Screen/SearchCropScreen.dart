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

  Future<void> _refreshData() async {
    await _waitForAuthAndFetchCrops();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover New Crops',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find and add crops to your farm',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
            tooltip: 'Refresh crops',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.roboto(fontSize: 16),
        decoration: InputDecoration(
          hintText: "Search for crops to add...",
          hintStyle: GoogleFonts.roboto(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.search, color: Colors.green[600], size: 24),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    final selected = _selectedCropIds.contains(crop['id']);
    final isAlreadyAdded = _existingCropNames.contains(crop['name'].toLowerCase());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: selected
            ? Border.all(color: Colors.green, width: 2)
            : Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isAlreadyAdded
                      ? Colors.grey.withOpacity(0.3)
                      : (selected ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                  image: DecorationImage(
                    image: AssetImage('assets/Image/${crop['name']}.jpg'),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {},
                    colorFilter: isAlreadyAdded
                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : null,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isAlreadyAdded
                        ? Colors.grey.withOpacity(0.3)
                        : (selected ? Colors.green.withOpacity(0.1) : Colors.transparent),
                  ),
                  child: Center(
                    child: selected
                        ? Icon(Icons.check_circle, color: Colors.green[600], size: 24)
                        : (isAlreadyAdded
                        ? Icon(Icons.lock, color: Colors.grey[600], size: 24)
                        : const SizedBox()),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop['name'],
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isAlreadyAdded ? Colors.grey[600] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          crop['type'] ?? 'Unknown',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (isAlreadyAdded) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Already Added',
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected && !isAlreadyAdded)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.check, color: Colors.green[600], size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today, color: Colors.blue[600], size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Set Planting Dates',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: _selectedCropIds.map((cropId) {
              final controller = _plantDateControllers[cropId]!;
              final crop = _availableCrops.firstWhere((c) => c['id'] == cropId);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crop['name'],
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            crop['type'] ?? '',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: controller,
                        readOnly: true,
                        style: GoogleFonts.roboto(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "Select planting date",
                          hintStyle: GoogleFonts.roboto(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                          ),
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.green[600]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onTap: () => _selectDate(cropId),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveSelectedCrops,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "Add Selected Crops (${_selectedCropIds.length})",
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 48,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for crops',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type in the search bar above to discover new crops for your farm',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 32),
          const SizedBox(height: 12),
          Text(
            'Error Loading Crops',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fetchError ?? 'Unknown error occurred',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
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
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              if (fetchError != null)
                _buildErrorCard()
              else if (_searchController.text.isEmpty)
                _buildEmptyState()
              else if (_filteredCrops.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.agriculture, color: Colors.green[600], size: 20),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
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
                _buildSaveButton(),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}