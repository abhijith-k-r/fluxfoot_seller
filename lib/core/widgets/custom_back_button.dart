import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';

// ! Custom Back Button
Padding customBackButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: WebColors.buttonPurple,
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.close, color: WebColors.iconWhite),
        tooltip: 'Back',
      ),
    ),
  );
}
