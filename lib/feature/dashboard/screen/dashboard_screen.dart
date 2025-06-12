import 'package:flutter/material.dart';
import 'package:car_conect_dashboard/core/resource/color_manager.dart';
import '../../users/services/user_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UserService _userService = UserService();
  int _totalUsers = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTotalUsers();
  }

  Future<void> _loadTotalUsers() async {
    try {
      final users = await _userService.getUsers();
      setState(() {
        _totalUsers = users.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,  
              crossAxisSpacing: 20,
               childAspectRatio: 1.7,
              children: [
                _buildStatCard(
                  'Total Users',
                  _isLoading ? '...' : _totalUsers.toString(),
                  Icons.people,
                  const Color(0xFF6C63FF),
                  const Color(0xFFF6F7FB),
                ),
                _buildStatCard(
                  'Total Cars',
                  '567',
                  Icons.directions_car,
                  const Color(0xFF00C49A),
                  const Color(0xFFF6F7FB),
                ),
                _buildStatCard(
                  'Showrooms',
                  '89',
                  Icons.store,
                  const Color(0xFFFFB259),
                  const Color(0xFFF6F7FB),
                ),
                _buildStatCard(
                  'Active Posts',
                  '2,345',
                  Icons.post_add,
                  const Color(0xFF3B82F6),
                  const Color(0xFFF6F7FB),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _buildRecentSection(
                    'Recent Users',
                    [
                      {'name': 'John Doe', 'type': 'Car Owner'},
                      {'name': 'Jane Smith', 'type': 'Showroom Owner'},
                      {'name': 'Mike Johnson', 'type': 'Car Owner'},
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildRecentSection(
                    'Recent Cars',
                    [
                      {'name': 'BMW X5', 'type': 'New Post'},
                      {'name': 'Mercedes C300', 'type': 'Updated'},
                      {'name': 'Toyota Camry', 'type': 'New Post'},
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

  Widget _buildStatCard(String title, String value, IconData icon,
      Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection(String title, List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          const Color(0xFF6C63FF).withOpacity(0.12),
                      child: Text(
                        item['name']![0],
                        style: const TextStyle(color: Color(0xFF6C63FF)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name']!,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            item['type']!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
