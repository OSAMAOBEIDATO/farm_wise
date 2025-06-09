import 'package:farm_wise/CropDetailsText/HealthyCrop.dart';
import 'package:farm_wise/CropDetailsText/IrrigationCrop.dart';
import 'package:farm_wise/CropDetailsText/TimeCrop.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:farm_wise/Screen/CropDetails.dart';
import 'package:flutter/material.dart';

class TabContentCropDetails extends StatelessWidget {
  final CropDetailTab activeTab;
  final CropData crop;

  const TabContentCropDetails({
    super.key,
    required this.activeTab,
    required this.crop,
  });

  @override
  Widget build(BuildContext context) {
    switch (activeTab) {
      case CropDetailTab.irrigation:
        return IrrigationCrop(
          irrigationcrop: crop.irrigationGuide,
          waterRequirement: crop.waterRequirement,
        );
      case CropDetailTab.healthy:
        return Healthycrop(
          fertilizers: crop.fertilizers,
          soilType: crop.soilType,
          sunlight: crop.sunlight,
          irrigationCrop: crop.irrigationGuide,
        );
      case CropDetailTab.time:
        return TimeCrop(
          harvestDate: crop.harvestDate,
          bestPlantingSeason: crop.bestPlantingSeason,
          cropName: crop.name,
          growingTime: crop.growingTime,
          harvestDateNumber: crop.harvestDateNumber,
          plantDate: crop.plantDate,
        );
    }
  }
}