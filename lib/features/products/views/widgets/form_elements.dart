// ignore_for_file: deprecated_member_use

//! --- Reusable Form Elements and Widgets ---
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/features/products/model/dropdown_model.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildTextField(
  BuildContext context,
  String label,
  String hint,
  TextEditingController? controller,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: WebColors.textBlack,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: TextStyle(color: WebColors.textBlack),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.openSans(
              color: WebColors.textBlack.withOpacity(0.5),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    ),
  );
}

// ! Description Form
Widget buildTextArea(
  BuildContext context,
  String label,
  String hint,
  TextEditingController controller,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: WebColors.textBlack,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 4,
          style: TextStyle(color: WebColors.textBlack),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.openSans(
              color: WebColors.textBlack.withOpacity(0.1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    ),
  );
}

//!  Product  dropdown fields
Widget buildDropdownField({
  required BuildContext context,
  required String label,
  required String hint,
  required Future<List<DropdownItemModel>> itemsFuture,
  required Function(String?) onChanged,
  String? selectedValue,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: WebColors.textBlack,
          ),
        ),
        const SizedBox(height: 6),
        FutureBuilder<List<DropdownItemModel>>(
          future: itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error loading data: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(strokeWidth: 2));
            }

            final List<DropdownItemModel> dropdownData = snapshot.data ?? [];

            return DropdownButtonFormField<String>(
              decoration: InputDecoration(border: OutlineInputBorder()),
              value: selectedValue,
              hint: Text(
                hint.isEmpty ? 'Select $label' : hint,
                style: GoogleFonts.openSans(
                  color: WebColors.textBlack.withOpacity(0.5),
                ),
              ),
              items: dropdownData.map((item) {
                return DropdownMenuItem<String>(
                  value: item.id,
                  child: Text(item.name),
                );
              }).toList(),

              onChanged: onChanged,
            );
          },
        ),
      ],
    ),
  );
}
