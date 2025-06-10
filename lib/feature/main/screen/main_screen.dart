import 'package:car_conect_dashboard/core/widget/container/decorated_container.dart';
import 'package:car_conect_dashboard/core/widget/text/app_text_widget.dart';
import 'package:car_conect_dashboard/feature/car/screens/cars_screen.dart';
import 'package:car_conect_dashboard/feature/dashboard/screen/dashboard_screen.dart';
import 'package:car_conect_dashboard/feature/orders/screens/orders_screen.dart';
import 'package:car_conect_dashboard/feature/reservations/screens/reservations_screen.dart';
import 'package:car_conect_dashboard/feature/statistics/screens/statistics_screen.dart';
import 'package:car_conect_dashboard/feature/users/screen/users_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class DrawerItem {
  final String title;
  final IconData icon;

  DrawerItem({required this.title, required this.icon});
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<DrawerItem> _drawerItems = [
    DrawerItem(title: 'Dashboard', icon: Icons.dashboard),
    DrawerItem(title: 'Users', icon: Icons.people),
    DrawerItem(title: 'Reports', icon: Icons.analytics),
    DrawerItem(title: 'Cars', icon: Icons.directions_car),
    DrawerItem(title: 'Reservations', icon: Icons.calendar_today),
    DrawerItem(title: 'Orders', icon: Icons.shopping_cart),
    DrawerItem(title: 'Showrooms', icon: Icons.store),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Modern Drawer
          DecoratedContainer(
            color: Colors.white,
            width: 220,
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(2, 0),
              ),
            ],
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Drawer Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _drawerItems.length,
                    itemBuilder: (context, index) {
                      final item = _drawerItems[index];
                      final isSelected = _selectedIndex == index;
                      return DecoratedContainer(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            item.icon,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                          title: AppTextWidget(
                            text: item.title,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          horizontalTitleGap: 12,
                          minLeadingWidth: 0,
                        ),
                      );
                    },
                  ),
                ),
                // Logout
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 24.0, left: 12, right: 12),
                  child: DecoratedContainer(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red[400]),
                      title: AppTextWidget(
                        text: "Logout",
                        color: Colors.red[400]!,
                        fontWeight: FontWeight.bold,
                      ),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      horizontalTitleGap: 12,
                      minLeadingWidth: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFF6F7FB),
              child: _getPage(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const UsersScreen();
      case 2:
        return const StatisticsScreen();
      case 3:
        return const CarsScreen();
      case 4:
        return const ReservationsScreen();
      case 5:
        return const OrdersScreen();
      case 6:
        return const Center(
            child: AppTextWidget(text: 'Showrooms Page', color: Colors.black));
      default:
        return const DashboardScreen();
    }
  }
}
