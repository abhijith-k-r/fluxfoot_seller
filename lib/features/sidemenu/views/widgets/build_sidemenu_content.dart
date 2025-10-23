// !====== For Sample Text====
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildDashboardContent() {
  return Center(
    child: Text(
      "Dashboard Content Here",
      style: GoogleFonts.openSans(color: Colors.black, fontSize: 24),
    ),
  );
}

Widget buildUserManagementContent() {
  return Center(
    child: Text(
      "User Management Content Here",
      style: GoogleFonts.openSans(color: Colors.white, fontSize: 24),
    ),
  );
}

Widget buildOrdersContent() {
  return Center(
    child: Text(
      "Orders Content Here",
      style: GoogleFonts.openSans(color: Colors.white, fontSize: 24),
    ),
  );
}
