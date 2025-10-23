import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/sidemenu/view_model/provider/side_menu_provider.dart';
import 'package:fluxfoot_seller/features/sidemenu/views/widgets/custom_sidemenu.dart';
import 'package:fluxfoot_seller/features/sidemenu/views/widgets/web_appbar.dart';
import 'package:provider/provider.dart';

class SideMenuScreen extends StatelessWidget {
  const SideMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SideMenuProvider>(
        builder: (context, sidemenuprovider, child) {
          return Column(
            children: [
              CustomWebAppbar(title: sidemenuprovider.currentPageTitle),

              // !Custom Side menu
              Expanded(
                child: Row(
                  children: [
                    CustomSideMenu(
                      menuItems: sidemenuprovider.menuItems,
                      selectedIndex: sidemenuprovider.selectedIndex,
                      onItemTap: sidemenuprovider.onMenuItemTap,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        // ! contents..!
                        child: sidemenuprovider.buildMainContent(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildDashboardContent() {
    return const Center(
      child: Text(
        "Dashboard Content Here",
        style: TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
  }

  Widget buildUserManagementContent() {
    return const Center(
      child: Text(
        "User Management Content Here",
        style: TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
  }

  Widget buildSellerManagementContent() {
    return const Center(
      child: Text(
        "Seller Management Content Here",
        style: TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
  }

  Widget buildOrdersContent() {
    return const Center(
      child: Text(
        "Orders Content Here",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}
