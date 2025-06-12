import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_links.dart';
import '../../../core/resource/color_manager.dart';
import '../../../core/resource/font_manager.dart';
import '../../../core/widget/loading/app_circular_progress_widget.dart';
import '../../../core/widget/text/app_text_widget.dart';
import '../../../core/utils/app_shared_preferences.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int status = -1;
  List<dynamic> orders = [];
  bool isUpdatingStatus = false;

  final Map<String, String> statusMap = {
    '0': 'Pending',
    '1': 'Accepted',
    '2': 'Rejected'
  };

  @override
  void initState() {
    super.initState();
    getAllOrders();
  }

  void getAllOrders() async {
    setState(() {
      status = 0;
    });

    try {
      final token = await AppSharedPreferences.getToken();
      print('Fetching orders from: ${ApiGetUrl.getAllOrders}');
      final response = await http.get(
        Uri.parse(ApiGetUrl.getAllOrders),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> rawOrders = json.decode(response.body);
        print('Decoded data: $rawOrders');
        
        // Transform the data to match the expected format
        final List<Map<String, dynamic>> transformedOrders = rawOrders.map((order) {
          return {
            'order': {
              'id': order['id'],
              'status': order['status'].toString(),
              'paymentType': order['paymentType'].toString(),
              'date': order['date'],
              'totalPrice': order['totalPrice'],
              'lat': order['lat'],
              'long': order['long'],
              'created_at': order['created_at'],
            },
            'car': {
              'desc': 'Car #${order['carId']}',
              'price': order['totalPrice'] ?? '0',
              'killo': '0',
              'rent': '0',
            },
            'customer': {
              'phone': 'N/A',
            },
            'businessOwner': {
              'name': 'N/A',
              'phone': 'N/A',
            },
          };
        }).toList();

        setState(() {
          status = 1;
          orders = transformedOrders;
        });
      } else {
        setState(() {
          status = 2;
        });
        _showErrorSnackBar('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        status = 2;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> changeOrderStatus(String orderId, String newStatus) async {
    setState(() {
      isUpdatingStatus = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiPostUrl.changeOrderStatus),
        body: {
          'orderId': orderId,
          'status': newStatus,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showSuccessSnackBar(data['message']);
        getAllOrders(); // Refresh the orders list
      } else {
        final data = json.decode(response.body);
        _showErrorSnackBar(data['error'] ?? 'Failed to update order status');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating order status: $e');
    } finally {
      setState(() {
        isUpdatingStatus = false;
      });
    }
  }

  void _showStatusChangeDialog(String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...statusMap.entries.map((entry) {
              // Don't show current status as an option
              if (entry.key == currentStatus) return const SizedBox.shrink();

              return ListTile(
                title: Text(entry.value),
                onTap: () {
                  Navigator.pop(context);
                  changeOrderStatus(orderId, entry.key);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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
          color: Colors.white,
          fontSize: FontSizeManager.fs16,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  String _getStatusColor(String status) {
    switch (status) {
      case '0':
        return '#FFD700'; // Pending - Yellow
      case '1':
        return '#4CAF50'; // Accepted - Green
      case '2':
        return '#F44336'; // Rejected - Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
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
                  text: "Orders",
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
                      const Icon(Icons.shopping_cart,
                          color: AppColorManager.navy, size: 20),
                      const SizedBox(width: 8),
                      AppTextWidget(
                        text: "${orders.length} Orders",
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
                                text: "Failed to load orders",
                                color: AppColorManager.navy,
                                fontSize: FontSizeManager.fs16,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: getAllOrders,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColorManager.navy,
                                ),
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
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
                                        color: order['order']['status'] == '0'
                                            ? AppColorManager.yellow
                                            : order['order']['status'] == '1'
                                                ? AppColorManager.green
                                                : AppColorManager.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: AppTextWidget(
                                        text: statusMap[order['order']['status']
                                                .toString()] ??
                                            'Unknown',
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
                                            text: order['car']['desc'],
                                            color: AppColorManager.black,
                                            fontSize: FontSizeManager.fs14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          const SizedBox(height: 4),
                                          AppTextWidget(
                                            text: _formatDate(
                                                order['order']['created_at']),
                                            color: AppColorManager.grey,
                                            fontSize: FontSizeManager.fs12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppTextWidget(
                                      text: "\$${order['car']['price']}",
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
                                          "Payment Type",
                                          order['order']['paymentType'] == 1
                                              ? "Card"
                                              : "Cash"),
                                      _buildDetailRow("Customer Phone",
                                          order['customer']['phone']),
                                      _buildDetailRow("Business Owner",
                                          order['businessOwner']['name']),
                                      _buildDetailRow("Business Phone",
                                          order['businessOwner']['phone']),
                                      if (order['car']['rent'] == 1)
                                        _buildDetailRow(
                                            "Rental Date",
                                            _formatDate(
                                                order['order']['date'])),
                                      _buildDetailRow("Car Mileage",
                                          "${order['car']['killo']} km"),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                final lat = double.tryParse(
                                                    order['order']['lat']
                                                        .toString());
                                                final long = double.tryParse(
                                                    order['order']['long']
                                                        .toString());
                                                if (lat != null &&
                                                    long != null) {
                                                  _openMap(lat, long);
                                                } else {
                                                  _showErrorSnackBar(
                                                      'Invalid location coordinates');
                                                }
                                              },
                                              icon:
                                                  const Icon(Icons.location_on),
                                              label:
                                                  const Text("View Location"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColorManager.navy,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: isUpdatingStatus
                                                  ? null
                                                  : () =>
                                                      _showStatusChangeDialog(
                                                          order['order']['id']
                                                              .toString(),
                                                          order['order']
                                                                  ['status']
                                                              .toString()),
                                              icon: const Icon(Icons.edit_note),
                                              label:
                                                  const Text("Change Status"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColorManager.navy,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
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
