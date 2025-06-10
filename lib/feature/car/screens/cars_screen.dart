import 'dart:convert';

import 'package:car_conect_dashboard/feature/car/screens/car_card.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/api/api_links.dart';
import '../../../core/resource/color_manager.dart';
import '../../../core/resource/font_manager.dart';
import '../../../core/resource/image_manager.dart';
import '../../../core/resource/size_manager.dart';
import '../../../core/widget/image/main_image_widget.dart';
import '../../../core/widget/loading/app_circular_progress_widget.dart';
import '../../../core/widget/text/app_text_widget.dart';
import '../model/car_response_entity.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  int status = -1;

  CarResponseEntity? cars;
  bool _isLoading = true;

  Future<void> getAllCars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(ApiGetUrl.getCars));

      if (response.statusCode == 200) {
        setState(() {
          cars = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load cars')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    getAllCars();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            getAllCars();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextWidget(
                            text: "Car Connect",
                            color: AppColorManager.white,
                            fontWeight: FontWeight.w600,
                            fontSize: FontSizeManager.fs20,
                            maxLines: 2,
                          ),
                          AppTextWidget(
                            text: "Latest cars",
                            color: AppColorManager.white,
                            fontWeight: FontWeight.w600,
                            fontSize: FontSizeManager.fs16,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      MainImageWidget(
                        imagePath: AppImageManager.main,
                        height: AppHeightManager.h8,
                        width: AppHeightManager.h8,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: AppHeightManager.h4,
                  ),
                  Visibility(
                    visible: !_isLoading,
                    replacement: Container(
                        height: AppHeightManager.h10,
                        alignment: Alignment.center,
                        child: const AppCircularProgressWidget()),
                    child: Visibility(
                      visible: (cars?.cars ?? []).isNotEmpty,
                      replacement: Center(
                        child: Container(
                          margin: EdgeInsets.only(top: AppHeightManager.h5),
                          height: AppHeightManager.h7,
                          child: AppTextWidget(
                            text: "No Cars",
                            color: Colors.white,
                            fontSize: FontSizeManager.fs16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      child: DynamicHeightGridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          builder: (context, index) {
                            return CarCard(
                              car: cars?.cars?[index],
                            );
                          },
                          itemCount: cars?.cars?.length ?? 0,
                          crossAxisCount: 4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
