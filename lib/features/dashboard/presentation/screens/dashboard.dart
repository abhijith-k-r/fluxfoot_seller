import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/dashboard/presentation/widgets/custom_sidemenu.dart';
import 'package:fluxfoot_seller/features/dashboard/presentation/widgets/web_appbar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String currentPageTitle = "Dashboard Overview";
  int selectedIndex = 0;

  final List<SideMenuItems> menuItems = [
    SideMenuItems(
      title: "Dashboard",
      icon: Icons.dashboard,
      pageTitle: "Dashboard Overview",
    ),
    SideMenuItems(
      title: "User Management",
      icon: Icons.people,
      pageTitle: "User Management",
    ),
    SideMenuItems(
      title: "Seller Management",
      icon: Icons.store,
      pageTitle: "Seller Management",
    ),
    SideMenuItems(
      title: "Orders",
      icon: Icons.shopping_cart,
      pageTitle: "Orders Management",
    ),
  ];

  void _onMenuItemTap(int index) {
    setState(() {
      selectedIndex = index;
      currentPageTitle = menuItems[index].pageTitle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomWebAppbar(title: currentPageTitle),

          // !Custom Side menu
          Expanded(
            child: Row(
              children: [
                CustomSideMenu(
                  menuItems: menuItems,
                  selectedIndex: selectedIndex,
                  onItemTap: _onMenuItemTap,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: buildMainContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainContent() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildUserManagementContent();
      case 2:
        return _buildSellerManagementContent();
      case 3:
        return _buildOrdersContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return const Center(
      child: Text(
        "Dashboard Content Here",
        style: TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
  }

  Widget _buildUserManagementContent() {
    return const Center(
      child: Text(
        "User Management Content Here",
        style: TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
  }

  Widget _buildSellerManagementContent() {
    return const Center(
      child: Text(
        "Seller Management Content Here",
        style: TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
  }

  Widget _buildOrdersContent() {
    return const Center(
      child: Text(
        "Orders Content Here",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}
