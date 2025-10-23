// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:google_fonts/google_fonts.dart';

Widget customSearchForm(double size, ProductProvider productProvider) {
  return SizedBox(
    width: size * 0.3,
    child: TextField(
      controller: productProvider.searchController,
      decoration: InputDecoration(
        hintText: 'Search Brands...',
        hintStyle: GoogleFonts.openSans(
          color: WebColors.textBlack.withOpacity(0.5),
        ),
        prefixIcon: Icon(Icons.search, size: 20, color: WebColors.iconGrey),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),

          borderSide: BorderSide(color: WebColors.borderSideGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: WebColors.buttonPurple),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  );
}
