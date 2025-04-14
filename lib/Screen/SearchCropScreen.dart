import 'package:farm_wise/Models/CropData.dart';
import 'package:farm_wise/Screen/HomeScreen.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/service/CropServics.dart';
import 'package:flutter/material.dart';
import '../comman/consta.dart';

class AddCropScreen extends StatefulWidget {
  static const String id = "AddCropScreen";
  final String userId;

  const AddCropScreen({super.key, required this.userId});

  @override
  _AddCropScreenState createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final CropService _cropService = CropService();
  final TextEditingController _searchController = TextEditingController();
  List<CropData> _crops = [];
  List<CropData> _filteredCrops = [];
  List<String> _selectedCropNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCrops();
    _searchController.addListener(_filterCrops);
  }

  Future<void> _loadCrops() async {
    final crops = await _cropService.getCrops();
    setState(() {
      _crops = crops;
      _filteredCrops = crops;
      _isLoading = false;
    });
  }

  void _filterCrops() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCrops = _crops.where((crop) {
        return crop.cropName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleCropSelection(String cropName) {
    setState(() {
      if (_selectedCropNames.contains(cropName)) {
        _selectedCropNames.remove(cropName);
      } else {
        _selectedCropNames.add(cropName);
      }
    });
  }

  Future<void> _addSelectedCrops() async {
    if (!_selectedCropNames.isEmpty) {
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Please select at least one crop.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final selectedCrops = _crops
        .where(
          (crop) => _selectedCropNames.contains(crop.cropName),
    )
        .toList();

    final now = DateTime.now();
    for (CropData existingCrop in selectedCrops) {
      final newCrop = CropData(
        cropId: '',
        userId: widget.userId,
        cropName: existingCrop.cropName,
        plantType: existingCrop.plantType,
        plantDate: existingCrop.plantDate,
        harvestDate: existingCrop.harvestDate,
        fertilizers: existingCrop.fertilizers,
        pesticides: existingCrop.pesticides,
        createdAt: DateTime.now(),
      );

      final result = await _cropService.addCrop(newCrop);
      if (result != 'Successfully') {
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: 'Error adding ${existingCrop.cropName}: $result',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    setState(() {
      _isLoading = false;
    });

    CustomSnackBar().ShowSnackBar(
      context: context,
      text: 'Crops added successfully!',
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomeScreen(userId: widget.userId)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'FarmWise',
          style: KTextStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Select the crops that you grow. You can define varieties later.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredCrops.isEmpty
                  ? const Center(
                child: Text(
                  'No crops found. Add crops on the next screen.',
                  style:
                  TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredCrops.length,
                itemBuilder: (context, index) {
                  final crop = _filteredCrops[index];
                  final isSelected =
                  _selectedCropNames.contains(crop.cropName);
                  return CheckboxListTile(
                    title: Text(crop.cropName),
                    value: isSelected,
                    onChanged: (bool? value) {
                      _toggleCropSelection(crop.cropName);
                    },
                    activeColor: Colors.green,
                    checkColor: Colors.white,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Crops selected: ${_selectedCropNames.isEmpty ? 'None' : _selectedCropNames.join(', ')}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addSelectedCrops,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'NEXT',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}