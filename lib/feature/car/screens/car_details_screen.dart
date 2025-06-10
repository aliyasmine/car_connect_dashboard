import 'dart:convert';

import 'package:car_conect_dashboard/core/resource/size_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_links.dart';
import '../../../core/resource/color_manager.dart';
import '../../../core/resource/font_manager.dart';
import '../../../core/widget/image/main_image_widget.dart';
import '../../../core/widget/loading/app_circular_progress_widget.dart';
import '../../../core/widget/text/app_text_widget.dart';

class CarDetailsArgs {
  final String carId;
  CarDetailsArgs({required this.carId});
}

class CarDetailsScreen extends StatefulWidget {
  final CarDetailsArgs args;

  const CarDetailsScreen({super.key, required this.args});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  int status = -1;
  Map<String, dynamic>? carDetails;
  Map<String, dynamic>? businessUserDetails;
  Map<String, dynamic>? carReports;
  int selectedImageIndex = 0;
  bool isUpdatingAvailability = false;
  bool isLoadingReports = false;

  void getCarDetails() async {
    setState(() {
      status = 0;
    });

    try {
      final response = await http.post(Uri.parse(ApiPostUrl.getCarDetails),
          body: {'id': widget.args.carId});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          status = 1;
          carDetails = data;
        });
        if (data['car']['userId'] != null) {
          getBusinessUserDetails(data['car']['userId'].toString());
        }
      } else {
        setState(() {
          status = 2;
        });
        _showErrorSnackBar('Failed to load car details');
      }
    } catch (e) {
      setState(() {
        status = 2;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void getBusinessUserDetails(String businessId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiPostUrl.getBusinessUser),
        body: {'id': businessId},
      );

      if (response.statusCode == 200) {
        setState(() {
          businessUserDetails = json.decode(response.body);
        });
      }
    } catch (e) {
      setState(() {});
    }
  }

  void toggleCarAvailability() async {
    setState(() {
      isUpdatingAvailability = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiPostUrl.toggleCarAvailability),
        body: {'carId': widget.args.carId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (carDetails != null && carDetails!['car'] != null) {
            carDetails!['car']['available'] = data['available'];
          }
        });
        _showSuccessSnackBar('Car availability updated successfully');
      } else {
        _showErrorSnackBar('Failed to update car availability');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating car availability');
    } finally {
      setState(() {
        isUpdatingAvailability = false;
      });
    }
  }

  void getCarReports() async {
    setState(() {
      isLoadingReports = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiPostUrl.getCarReports),
        body: {'carId': widget.args.carId},
      );

      if (response.statusCode == 200) {
        setState(() {
          carReports = json.decode(response.body);
        });
      } else {
        _showErrorSnackBar('Failed to load reports');
      }
    } catch (e) {
      _showErrorSnackBar('Error loading reports');
    } finally {
      setState(() {
        isLoadingReports = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColorManager.white,
        content: AppTextWidget(
          text: message,
          color: AppColorManager.navy,
          fontSize: FontSizeManager.fs16,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: AppTextWidget(
          text: message,
          color: AppColorManager.white,
          fontSize: FontSizeManager.fs16,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCarDetails();
    getCarReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: AppTextWidget(
          text: "Car Details",
          color: AppColorManager.white,
          fontSize: FontSizeManager.fs20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColorManager.navy,
        elevation: 0,
      ),
      body: status == 0
          ? const Center(child: AppCircularProgressWidget())
          : status == 2
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTextWidget(
                        text: "Failed to load car details",
                        color: AppColorManager.navy,
                        fontSize: FontSizeManager.fs16,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: getCarDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorManager.navy,
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Stats
                      Row(
                        children: [
                          _buildStatCard(
                            "Views",
                            carDetails?['views']?.toString() ?? '0',
                            Icons.visibility,
                            Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            "Likes",
                            carDetails?['likes']?.toString() ?? '0',
                            Icons.favorite,
                            Colors.red,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            "Rating",
                            (carDetails?['rate'] ?? 0.0).toStringAsFixed(1),
                            Icons.star,
                            Colors.amber,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Main Content
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column - Images and Basic Info
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Main Image
                                if ((carDetails?['images'] as List?)
                                        ?.isNotEmpty ??
                                    false)
                                  Container(
                                    height: 400,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: MainImageWidget(
                                        imageUrl: imageUrl +
                                            (carDetails?['images']
                                                        [selectedImageIndex]
                                                    ['imageUrl'] ??
                                                ''),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                // Thumbnail Images
                                if ((carDetails?['images'] as List?)
                                        ?.isNotEmpty ??
                                    false)
                                  SizedBox(
                                    height: 80,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          ((carDetails?['images'] as List?)
                                                  ?.length ??
                                              0),
                                      itemBuilder: (context, index) {
                                        final image = (carDetails?['images']
                                            as List)[index];
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedImageIndex = index;
                                            });
                                          },
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            width: 80,
                                            decoration: BoxDecoration(
                                              border: selectedImageIndex ==
                                                      index
                                                  ? Border.all(
                                                      color:
                                                          AppColorManager.navy,
                                                      width: 2)
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: MainImageWidget(
                                                imageUrl: imageUrl +
                                                    (image['imageUrl'] ?? ''),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                // Basic Info Card
                                _buildInfoCard(
                                  "Car Information",
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: AppTextWidget(
                                              text: carDetails?['car']
                                                      ?['desc'] ??
                                                  '',
                                              color: AppColorManager.black,
                                              fontSize: FontSizeManager.fs18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: carDetails?['car']
                                                          ?['rent'] ==
                                                      1
                                                  ? AppColorManager.navy
                                                  : AppColorManager.background,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: AppTextWidget(
                                              text: carDetails?['car']
                                                          ?['rent'] ==
                                                      1
                                                  ? "For Rent"
                                                  : "For Sale",
                                              color: AppColorManager.white,
                                              fontSize: FontSizeManager.fs14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDetailRow(
                                        "Price",
                                        "\$${carDetails?['car']?['price'] ?? ''}",
                                        Icons.attach_money,
                                      ),
                                      _buildDetailRow(
                                        "Mileage",
                                        "${carDetails?['car']?['killo'] ?? ''} km",
                                        Icons.speed,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildDetailRow(
                                              "Availability",
                                              carDetails?['car']
                                                          ?['available'] ==
                                                      1
                                                  ? "Available"
                                                  : "Not Available",
                                              Icons.check_circle,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: isUpdatingAvailability
                                                ? null
                                                : toggleCarAvailability,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  carDetails?['car']
                                                              ?['available'] ==
                                                          1
                                                      ? Colors.red.shade100
                                                      : Colors.green.shade100,
                                              foregroundColor:
                                                  carDetails?['car']
                                                              ?['available'] ==
                                                          1
                                                      ? Colors.red
                                                      : Colors.green,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (isUpdatingAvailability)
                                                  const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                else
                                                  Icon(
                                                    carDetails?['car']?[
                                                                'available'] ==
                                                            1
                                                        ? Icons.cancel_outlined
                                                        : Icons
                                                            .check_circle_outline,
                                                  ),
                                                const SizedBox(width: 8),
                                                AppTextWidget(
                                                  text: carDetails?['car']
                                                              ?['available'] ==
                                                          1
                                                      ? "Mark as Unavailable"
                                                      : "Mark as Available",
                                                  fontSize:
                                                      FontSizeManager.fs14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right Column - Specifications and Owner Details
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                // Specifications Card
                                _buildInfoCard(
                                  "Specifications",
                                  Column(
                                    children: [
                                      _buildDetailRow(
                                        "Brand",
                                        carDetails?['brand']?['name'] ?? '',
                                        Icons.branding_watermark,
                                      ),
                                      _buildDetailRow(
                                        "Model",
                                        carDetails?['model']?['name'] ?? '',
                                        Icons.model_training,
                                      ),
                                      _buildDetailRow(
                                        "Color",
                                        carDetails?['color']?['name'] ?? '',
                                        Icons.color_lens,
                                      ),
                                      _buildDetailRow(
                                        "Gear",
                                        carDetails?['gear']?['name'] ?? '',
                                        Icons.settings,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Business Owner Card
                                _buildInfoCard(
                                  "Business Owner",
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (businessUserDetails != null) ...[
                                        // Show data from business user API
                                        if (businessUserDetails?['user']
                                                ?['type'] ==
                                            1)
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 16),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColorManager.navy
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.business,
                                                  size: 16,
                                                  color: AppColorManager.navy,
                                                ),
                                                const SizedBox(width: 8),
                                                AppTextWidget(
                                                  text: "Company Account",
                                                  color: AppColorManager.navy,
                                                  fontSize:
                                                      FontSizeManager.fs12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
                                          ),
                                        _buildDetailRow(
                                          "Name",
                                          businessUserDetails?['user']
                                                  ?['name'] ??
                                              '',
                                          Icons.person,
                                        ),
                                        _buildDetailRow(
                                          "Phone",
                                          businessUserDetails?['user']
                                                  ?['phone'] ??
                                              '',
                                          Icons.phone,
                                        ),
                                        if (businessUserDetails?['user']
                                                    ?['desc']
                                                ?.isNotEmpty ??
                                            false)
                                          _buildDetailRow(
                                            "Description",
                                            businessUserDetails?['user']
                                                ?['desc'],
                                            Icons.description,
                                          ),
                                        if (businessUserDetails?['user']
                                                    ?['lat'] !=
                                                null &&
                                            businessUserDetails?['user']
                                                    ?['long'] !=
                                                null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: ElevatedButton(
                                              onPressed: () => _openMap(
                                                double.parse(
                                                    businessUserDetails!['user']
                                                            ['lat']
                                                        .toString()),
                                                double.parse(
                                                    businessUserDetails!['user']
                                                            ['long']
                                                        .toString()),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColorManager.navy,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.location_on,
                                                      color: Colors.white),
                                                  const SizedBox(width: 8),
                                                  AppTextWidget(
                                                    text: "View Location",
                                                    color: Colors.white,
                                                    fontSize:
                                                        FontSizeManager.fs14,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (businessUserDetails?['user']
                                                    ?['type'] ==
                                                1 &&
                                            businessUserDetails?['user']?[
                                                    'commercialRegisterImageUrl'] !=
                                                null) ...[
                                          const SizedBox(height: 16),
                                          AppTextWidget(
                                            text: "Commercial Register",
                                            color: AppColorManager.grey,
                                            fontSize: FontSizeManager.fs14,
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 200,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: MainImageWidget(
                                                imageUrl: imageUrl +
                                                    (businessUserDetails?[
                                                                'user']?[
                                                            'commercialRegisterImageUrl'] ??
                                                        ''),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (businessUserDetails?['user']
                                                    ?['type'] ==
                                                0 &&
                                            businessUserDetails?['user']
                                                    ?['idImageUrl'] !=
                                                null) ...[
                                          const SizedBox(height: 16),
                                          AppTextWidget(
                                            text: "ID Card",
                                            color: AppColorManager.grey,
                                            fontSize: FontSizeManager.fs14,
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 200,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: MainImageWidget(
                                                imageUrl: imageUrl +
                                                    (businessUserDetails?[
                                                                'user']
                                                            ?['idImageUrl'] ??
                                                        ''),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ] else ...[
                                        // Show basic info while loading or if API fails
                                        if (carDetails?['businessOwner']
                                                ?['type'] ==
                                            'company')
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 16),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColorManager.navy
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.business,
                                                  size: 16,
                                                  color: AppColorManager.navy,
                                                ),
                                                const SizedBox(width: 8),
                                                AppTextWidget(
                                                  text: "Company Account",
                                                  color: AppColorManager.navy,
                                                  fontSize:
                                                      FontSizeManager.fs12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
                                          ),
                                        _buildDetailRow(
                                          "Name",
                                          carDetails?['businessOwner']
                                                  ?['name'] ??
                                              '',
                                          Icons.person,
                                        ),
                                        _buildDetailRow(
                                          "Phone",
                                          carDetails?['businessOwner']
                                                  ?['phone'] ??
                                              '',
                                          Icons.phone,
                                        ),
                                        if (carDetails?['businessOwner']
                                                    ?['desc']
                                                ?.isNotEmpty ??
                                            false)
                                          _buildDetailRow(
                                            "Description",
                                            carDetails?['businessOwner']
                                                ?['desc'],
                                            Icons.description,
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Ownership Document
                                if (carDetails?['car']?['ownerShipImageUrl']
                                        ?.isNotEmpty ??
                                    false)
                                  _buildInfoCard(
                                    "Ownership Document",
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: MainImageWidget(
                                          imageUrl: imageUrl +
                                              (carDetails?['car']
                                                      ?['ownerShipImageUrl'] ??
                                                  ''),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  )
                                else if (carDetails?['businessOwner']
                                        ?['type'] ==
                                    'company')
                                  _buildInfoCard(
                                    "Ownership Document",
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColorManager.navy
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: AppColorManager.navy,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: AppTextWidget(
                                              text:
                                                  "This is a company account. No ownership document is required.",
                                              color: AppColorManager.navy,
                                              fontSize: FontSizeManager.fs14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  height: AppHeightManager.h1point8,
                                ),

                                // Comments Section
                                if ((carDetails?['comments'] as List?)
                                        ?.isNotEmpty ??
                                    false)
                                  _buildInfoCard(
                                    "Comments",
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              (carDetails?['comments'] as List)
                                                  .length,
                                          itemBuilder: (context, index) {
                                            final comment =
                                                (carDetails?['comments']
                                                    as List)[index];
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 16),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .person_outline,
                                                            size: 16,
                                                            color:
                                                                AppColorManager
                                                                    .navy,
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          AppTextWidget(
                                                            text: comment[
                                                                        'user']
                                                                    ['phone'] ??
                                                                'Unknown',
                                                            color:
                                                                AppColorManager
                                                                    .navy,
                                                            fontSize:
                                                                FontSizeManager
                                                                    .fs14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ],
                                                      ),
                                                      AppTextWidget(
                                                        text: _formatDate(
                                                            comment[
                                                                'created_at']),
                                                        color: AppColorManager
                                                            .grey,
                                                        fontSize:
                                                            FontSizeManager
                                                                .fs12,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  AppTextWidget(
                                                    text: comment['comment'] ??
                                                        '',
                                                    color:
                                                        AppColorManager.black,
                                                    fontSize:
                                                        FontSizeManager.fs14,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 24),

                                // Reports Section
                                if (!isLoadingReports &&
                                    carReports != null &&
                                    (carReports!['reports'] as List?)
                                            ?.isNotEmpty ==
                                        true)
                                  _buildInfoCard(
                                    "Reports",
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              (carReports!['reports'] as List)
                                                  .length,
                                          itemBuilder: (context, index) {
                                            final report =
                                                (carReports!['reports']
                                                    as List)[index];
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 16),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.red[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .warning_amber_rounded,
                                                            size: 16,
                                                            color: Colors.red,
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          AppTextWidget(
                                                            text: report['user']
                                                                    ['phone'] ??
                                                                'Unknown',
                                                            color: Colors.red,
                                                            fontSize:
                                                                FontSizeManager
                                                                    .fs14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ],
                                                      ),
                                                      AppTextWidget(
                                                        text: _formatDate(
                                                            report[
                                                                'created_at']),
                                                        color: AppColorManager
                                                            .grey,
                                                        fontSize:
                                                            FontSizeManager
                                                                .fs12,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  AppTextWidget(
                                                    text:
                                                        report['content'] ?? '',
                                                    color:
                                                        AppColorManager.black,
                                                    fontSize:
                                                        FontSizeManager.fs14,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            AppTextWidget(
              text: value,
              color: AppColorManager.black,
              fontSize: FontSizeManager.fs18,
              fontWeight: FontWeight.w600,
            ),
            AppTextWidget(
              text: label,
              color: AppColorManager.grey,
              fontSize: FontSizeManager.fs12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextWidget(
            text: title,
            color: AppColorManager.navy,
            fontSize: FontSizeManager.fs18,
            fontWeight: FontWeight.w600,
          ),
          const Divider(height: 24),
          content,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColorManager.navy,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextWidget(
                text: label,
                color: AppColorManager.grey,
                fontSize: FontSizeManager.fs12,
              ),
              AppTextWidget(
                text: value,
                color: AppColorManager.black,
                fontSize: FontSizeManager.fs14,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openMap(double lat, double long) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showErrorSnackBar('Could not open map');
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
