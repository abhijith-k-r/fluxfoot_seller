// Separate Widget for Web Layout
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/auth/presentation/widgets/login_form.dart';
import 'package:google_fonts/google_fonts.dart';

class WebLoginLayout extends StatelessWidget {
  const WebLoginLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo/logo.png',
                  width: size.width * 0.1,
                  height: size.height * 0.1,
                ),
                Text(
                  'FLUXFOOT',
                  style: GoogleFonts.rozhaOne(fontSize: size.width * 0.02),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: Center(child: LoginForm())),
      ],
    );
  }
}
