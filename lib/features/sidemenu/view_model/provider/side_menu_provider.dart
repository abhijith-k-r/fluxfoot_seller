import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/products/views/screen/product_manage_screen.dart';
import 'package:fluxfoot_seller/features/sidemenu/model/sidemenu_item_model.dart';
import 'package:fluxfoot_seller/features/sidemenu/views/widgets/build_sidemenu_content.dart';

class SideMenuProvider extends ChangeNotifier {
  String _currentPageTitle = "Dashboard Overview";
  int _selectedIndex = 0;

  String get currentPageTitle => _currentPageTitle;
  int get selectedIndex => _selectedIndex;

  final List<SideMenuItems> menuItems = [
    SideMenuItems(
      title: "Dashboard",
      icon: Icons.dashboard,
      pageTitle: "Dashboard Overview",
    ),
    SideMenuItems(
      title: "Products Management",
      icon: CupertinoIcons.bag,
      pageTitle: "Products Management",
    ),
    SideMenuItems(
      title: "Orders",
      icon: Icons.shopping_cart,
      pageTitle: "Orders Management",
    ),
  ];

  void onMenuItemTap(int index) {
    _selectedIndex = index;
    _currentPageTitle = menuItems[index].pageTitle;
    notifyListeners();
  }

  Widget buildMainContent(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return buildDashboardContent();
      case 1:
        return ProductManageScreen();
      case 2:
        return buildOrdersContent();
      default:
        return buildDashboardContent();
    }
  }
}
