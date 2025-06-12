import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/api/api_links.dart';
import '../../../core/resource/color_manager.dart';
import '../../../core/resource/font_manager.dart';
import '../../../core/widget/loading/app_circular_progress_widget.dart';
import '../../../core/widget/text/app_text_widget.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  int status = -1;
  List<dynamic> reservations = [];

  @override
  void initState() {
    super.initState();
    getAllReservations();
  }

  void getAllReservations() async {
    setState(() {
      status = 0;
    });

    try {
      final response = await http.get(Uri.parse(ApiGetUrl.getAllReservations));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          status = 1;
          reservations = data['reservations'];
        });
      } else {
        setState(() {
          status = 2;
        });
        _showErrorSnackBar('Failed to load reservations');
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  void _showReservationDetails(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reservation Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start Date: ${reservation['reservation']['startDate']}'),
                Text('End Date: ${reservation['reservation']['endDate']}'),
                Text(
                    'Total Price: \$${reservation['reservation']['totalPrice']}'),
                Text('Status: ${reservation['reservation']['status']}'),
                const SizedBox(height: 20),
                Text('Car: ${reservation['car']['name']}'),
                Text('Model: ${reservation['car']['model']}'),
                Text('Year: ${reservation['car']['year']}'),
                const SizedBox(height: 20),
                Text('User: ${reservation['user']['name']}'),
                Text('Email: ${reservation['user']['email']}'),
                Text('Phone: ${reservation['user']['phone']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppTextWidget(
                  text: "Reservations",
                  color: AppColorManager.navy,
                  fontSize: FontSizeManager.fs24,
                  fontWeight: FontWeight.w600,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColorManager.navy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColorManager.navy, size: 20),
                      const SizedBox(width: 8),
                      AppTextWidget(
                        text: "${reservations.length} Reservations",
                        color: AppColorManager.navy,
                        fontSize: FontSizeManager.fs14,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: status == 0
                  ? const Center(child: AppCircularProgressWidget())
                  : status == 2
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppTextWidget(
                                text: "Failed to load reservations",
                                color: AppColorManager.navy,
                                fontSize: FontSizeManager.fs16,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: getAllReservations,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColorManager.navy,
                                ),
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: reservations.length,
                          itemBuilder: (context, index) {
                            final reservation = reservations[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.all(16),
                                childrenPadding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColorManager.navy,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: AppTextWidget(
                                        text:
                                            "${_formatDate(reservation['reservation']['startDate'] ?? "") ?? ''} - ${_formatDate(reservation['reservation']['endDate'] ?? "") ?? ''}",
                                        color: Colors.white,
                                        fontSize: FontSizeManager.fs12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AppTextWidget(
                                            text: reservation['car']['desc'],
                                            color: AppColorManager.black,
                                            fontSize: FontSizeManager.fs14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          const SizedBox(height: 4),
                                          AppTextWidget(
                                            text: reservation['reservation']
                                                ['startDate'],
                                            color: AppColorManager.grey,
                                            fontSize: FontSizeManager.fs12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppTextWidget(
                                      text:
                                          "\$${reservation['reservation']['total']}",
                                      color: AppColorManager.navy,
                                      fontSize: FontSizeManager.fs16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                          "Start Date",
                                          reservation['reservation']
                                              ['startDate']),
                                      _buildDetailRow(
                                          "End Date",
                                          reservation['reservation']
                                              ['endDate']),
                                      _buildDetailRow(
                                        "Customer Phone",
                                        reservation['customer']['phone'],
                                      ),
                                      _buildDetailRow(
                                        "Business Owner",
                                        reservation['businessOwner']['name'],
                                      ),
                                      _buildDetailRow(
                                        "Business Phone",
                                        reservation['businessOwner']['phone'],
                                      ),
                                      _buildDetailRow(
                                        "Car Mileage",
                                        "${reservation['car']['killo']} km",
                                      ),
                                      _buildDetailRow(
                                        "Daily Rate",
                                        "\$${reservation['car']['price']}",
                                      ),
                                      _buildDetailRow(
                                        "Total Amount",
                                        "\$${reservation['reservation']['total']}",
                                      ),
                                    ],
                                  ),
                                ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: AppTextWidget(
              text: "$label   :    ",
              color: AppColorManager.grey,
              fontSize: FontSizeManager.fs14,
            ),
          ),
          Expanded(
            child: AppTextWidget(
              text: value,
              color: AppColorManager.black,
              fontSize: FontSizeManager.fs14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
