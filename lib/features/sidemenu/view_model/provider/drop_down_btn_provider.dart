import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';
import 'package:fluxfoot_seller/features/auth/views/screens/loging_screenn.dart';
import 'package:provider/provider.dart';

class DropDownButtonProvider extends ChangeNotifier {
  String? _value;

  String get value => _value!;

  void isSelected(BuildContext context, String value) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (value == 'log_out') {
      auth.signOut();
      fadePushAndRemoveUntil(context, LoginScreen());
    }
    notifyListeners();
  }
}

class SellerDropdown extends StatelessWidget {
  const SellerDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildAdminDropdown(context);
  }

  Widget _buildAdminDropdown(BuildContext context) {
    return Consumer<DropDownButtonProvider>(
      builder: (context, dropdownButton, child) {
        return PopupMenuButton<String>(
          // Button to trigger the dropdown
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            // Non-clickable "Admin" title
            PopupMenuItem<String>(
              enabled: false, // Disables clicking
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  'Seller',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // Clickable "Log Out" option
            PopupMenuItem<String>(
              value: 'log_out',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Log Out'),
                ],
              ),
            ),
            // Placeholder for future fields (empty space)
            PopupMenuItem<String>(
              enabled: false, // Disables clicking
              child: SizedBox(height: 16.0), // Reserved space for future items
            ),
          ],
          // Callback when a menu item is selected
          onSelected: (value) => dropdownButton.isSelected(context, value),
          // Customize the popup menu appearance
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4.0,
          color: Colors.white,
          // Button to trigger the dropdown
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color:
                  Colors.deepPurpleAccent, 
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                Text(
                  'Seller',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
