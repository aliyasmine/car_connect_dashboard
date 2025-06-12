import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_links.dart';
import '../../../core/resource/color_manager.dart';
import '../../../core/resource/font_manager.dart';
import '../../../core/widget/button/main_app_button.dart';
import '../../../core/widget/image/main_image_widget.dart';
import '../../../core/widget/loading/app_circular_progress_widget.dart';
import '../../../core/widget/text/app_text_widget.dart';
import '../../car/screens/car_details_screen.dart';

class BusinessDetailsArgs {
  final String businessId;
  BusinessDetailsArgs({required this.businessId});
}

class BusinessDetailsScreen extends StatefulWidget {
  final BusinessDetailsArgs args;

  const BusinessDetailsScreen({super.key, required this.args});

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  int status = -1;
  Map<String, dynamic>? businessDetails;

  void getBusinessDetails() async {
    setState(() {
      status = 0;
    });

    try {
      final response = await http.post(Uri.parse(ApiPostUrl.getBusinessUser),
          body: {'id': widget.args.businessId});

      if (response.statusCode == 200) {
        setState(() {
          status = 1;
          businessDetails = json.decode(response.body);
        });
      } else {
        setState(() {
          status = 2;
        });
        _showErrorSnackBar('Failed to load business details');
      }
    } catch (e) {
      setState(() {
        status = 2;
      });
      _showErrorSnackBar('Error: $e');
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

  void _openMap(double lat, double long) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showErrorSnackBar('Could not open map');
    }
  }

  @override
  void initState() {
    super.initState();
    getBusinessDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: AppTextWidget(
          text: "Business Details",
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
                        text: "Failed to load business details",
                        color: AppColorManager.navy,
                        fontSize: FontSizeManager.fs16,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: getBusinessDetails,
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
                      // Business Info Card
                      _buildInfoCard(
                        "Business Information",
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow(
                                        "Name",
                                        businessDetails?['user']?['name'] ?? '',
                                        Icons.business,
                                      ),
                                      _buildDetailRow(
                                        "Phone",
                                        businessDetails?['user']?['phone'] ??
                                            '',
                                        Icons.phone,
                                      ),
                                      if (businessDetails?['user']?['desc']
                                              ?.isNotEmpty ??
                                          false)
                                        _buildDetailRow(
                                          "Description",
                                          businessDetails?['user']?['desc'],
                                          Icons.description,
                                        ),
                                    ],
                                  ),
                                ),
                                if (businessDetails?['user']?['type'] == 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColorManager.navy.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.business_center,
                                          size: 16,
                                          color: AppColorManager.navy,
                                        ),
                                        const SizedBox(width: 8),
                                        AppTextWidget(
                                          text: "Company Account",
                                          color: AppColorManager.navy,
                                          fontSize: FontSizeManager.fs12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Location
                            if (businessDetails?['user']?['lat'] != null &&
                                businessDetails?['user']?['long'] != null)
                              MainAppButton(
                                onTap: () => _openMap(
                                  double.parse(businessDetails!['user']['lat']
                                      .toString()),
                                  double.parse(businessDetails!['user']['long']
                                      .toString()),
                                ),
                                color: AppColorManager.navy,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    AppTextWidget(
                                      text: "View Location",
                                      color: Colors.white,
                                      fontSize: FontSizeManager.fs14,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Documents Section
                      if (businessDetails?['user']?['type'] == 1 &&
                          businessDetails?['user']
                                  ?['commercialRegisterImageUrl'] !=
                              null)
                        _buildInfoCard(
                          "Business Documents",
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: MainImageWidget(
                                    imageUrl: imageUrl +
                                        (businessDetails?['user']?[
                                                'commercialRegisterImageUrl'] ??
                                            ''),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (businessDetails?['user']?['type'] == 0 &&
                          businessDetails?['user']?['idImageUrl'] != null) ...[
                        const SizedBox(height: 24),
                        _buildInfoCard(
                          "Identity Document",
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: MainImageWidget(
                                    imageUrl: imageUrl +
                                        (businessDetails?['user']
                                                ?['idImageUrl'] ??
                                            ''),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Cars Grid
                      if ((businessDetails?['cars'] as List?)?.isNotEmpty ??
                          false)
                        _buildInfoCard(
                          "Available Cars",
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount:
                                (businessDetails?['cars'] as List).length,
                            itemBuilder: (context, index) {
                              final car =
                                  (businessDetails?['cars'] as List)[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CarDetailsScreen(
                                        args: CarDetailsArgs(
                                            carId: car['id'].toString()),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if ((car['images'] as List?)
                                              ?.isNotEmpty ??
                                          false)
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                            child: MainImageWidget(
                                              imageUrl: imageUrl +
                                                  (car['images'][0]
                                                          ['imageUrl'] ??
                                                      ''),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppTextWidget(
                                              text: car['desc'] ?? '',
                                              color: AppColorManager.black,
                                              fontSize: FontSizeManager.fs14,
                                              fontWeight: FontWeight.w600,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                AppTextWidget(
                                                  text: "\$${car['price']}",
                                                  color: AppColorManager.navy,
                                                  fontSize:
                                                      FontSizeManager.fs14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: car['rent'] == 1
                                                        ? AppColorManager.navy
                                                        : AppColorManager
                                                            .background,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: AppTextWidget(
                                                    text: car['rent'] == 1
                                                        ? "Rent"
                                                        : "Sale",
                                                    color: Colors.white,
                                                    fontSize:
                                                        FontSizeManager.fs12,
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
                              );
                            },
                          ),
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
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }
}
