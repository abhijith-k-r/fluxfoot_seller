// ! Custom Side Menu
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:fluxfoot_seller/features/sidemenu/model/sidemenu_item_model.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSideMenu extends StatelessWidget {
  final List<SideMenuItems> menuItems;
  final int selectedIndex;
  final Function(int) onItemTap;

  const CustomSideMenu({
    super.key,
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size.width;
    return SideMenu(
      backgroundColor: const Color(0xFFE0E0E0),
      builder: (data) => SideMenuData(
        header: Container(
          padding: const EdgeInsets.all(10),
          child: const SizedBox(height: 10),
        ),
        items: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = selectedIndex == index;

          return SideMenuItemDataTile(
            isSelected: isSelected,
            onTap: () => onItemTap(index),
            title: item.title,
            icon: Icon(
              item.icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 20,
            ),
            selectedTitleStyle: isSelected
                ? GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )
                : GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
            borderRadius: BorderRadius.circular(8),
            highlightSelectedColor: Colors.deepPurpleAccent,
          );
        }).toList(),
      ),
    );
  }
}

