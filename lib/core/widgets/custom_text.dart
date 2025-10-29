// ! Custome Text
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

Widget customText(
  double size,
  String text, {
  FontWeight? fontWeight,
  Color? webcolors,
  TextOverflow? overflow,
}) {
  return Text(
    text,
    style: GoogleFonts.openSans(
      color: webcolors ?? WebColors.textBlack,
      fontSize: size,
      fontWeight: fontWeight,
    ),
    overflow: TextOverflow.ellipsis,
  );
}
