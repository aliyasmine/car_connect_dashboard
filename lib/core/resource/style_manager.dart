import 'package:car_conect_dashboard/core/resource/color_manager.dart';
import 'package:car_conect_dashboard/core/resource/size_manager.dart';
import 'package:flutter/material.dart';
 
abstract class AppStyleManager{
  static VisualDensity checkBoxVisualDensity = const VisualDensity(horizontal: -4);
  static double cardImageSize =AppWidthManager.w13;
  static BoxShadow cardImageShadow =BoxShadow(
    color: AppColorManager.greyShadow,
    spreadRadius: 2,
    blurRadius: 10,
  );
}