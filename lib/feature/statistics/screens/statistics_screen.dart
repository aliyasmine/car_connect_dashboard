import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../core/api/api_links.dart';
import '../../../core/resource/color_manager.dart';
import '../../../core/resource/font_manager.dart';
import '../../../core/widget/loading/app_circular_progress_widget.dart';
import '../../../core/widget/text/app_text_widget.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int status = -1;
  Map<String, dynamic>? statistics;
  String selectedPeriod = 'month';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getStatistics();
  }

  Future<void> getStatistics() async {
    setState(() {
      status = 0;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiGetUrl.getStatistics),
        body: {
          'period': selectedPeriod,
          'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          status = 1;
          statistics = data;
        });
      } else {
        setState(() {
          status = 2;
        });
        _showErrorSnackBar(
            'Failed to load statistics. Status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      setState(() {
        status = 2;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
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
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDateFilter(),
            const SizedBox(height: 24),
            Expanded(
              child: status == 0
                  ? const Center(child: AppCircularProgressWidget())
                  : status == 2
                      ? _buildErrorState()
                      : statistics == null
                          ? const Center(child: Text('No data available'))
                          : _buildStatisticsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppTextWidget(
          text: "Statistics & Analytics",
                 fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
             
        ),
        ElevatedButton.icon(
          onPressed: getStatistics,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorManager.navy,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Period',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'day', child: Text('Daily')),
                DropdownMenuItem(value: 'month', child: Text('Monthly')),
                DropdownMenuItem(value: 'year', child: Text('Yearly')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedPeriod = value;
                  });
                  getStatistics();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                  getStatistics();
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          AppTextWidget(
            text: "Failed to load statistics",
            color: AppColorManager.navy,
            fontSize: FontSizeManager.fs16,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: getStatistics,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorManager.navy,
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent() {
    if (statistics == null || !statistics!.containsKey('metrics')) {
      return const Center(child: Text('Invalid data format'));
    }

    final metrics = statistics!['metrics'];

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  "Total Orders",
                  metrics['orders']?['total']?.toString() ?? '0',
                  Icons.shopping_cart,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  "Active Reservations",
                  metrics['reservations']?['active']?.toString() ?? '0',
                  Icons.calendar_today,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildEngagementMetrics(metrics),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          AppTextWidget(
            text: value,
            color: AppColorManager.black,
            fontSize: FontSizeManager.fs24,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          AppTextWidget(
            text: label,
            color: AppColorManager.grey,
            fontSize: FontSizeManager.fs14,
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementMetrics(Map<String, dynamic> metrics) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextWidget(
            text: "Engagement Metrics",
            color: AppColorManager.navy,
            fontSize: FontSizeManager.fs18,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildEngagementCard(
                  "Likes",
                  metrics['likes']?['total']?.toString() ?? '0',
                  Icons.favorite,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEngagementCard(
                  "Reports",
                  metrics['reports']?['total']?.toString() ?? '0',
                  Icons.report_problem,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEngagementCard(
                  "Comments",
                  metrics['comments']?['total']?.toString() ?? '0',
                  Icons.comment,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEngagementCard(
                  "Average Rating",
                  (metrics['rates']?['average'] ?? 0.0).toStringAsFixed(1),
                  Icons.star,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
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
    );
  }
}
