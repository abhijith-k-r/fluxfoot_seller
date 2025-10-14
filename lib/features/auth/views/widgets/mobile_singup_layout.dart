// Separate Widget for Mobile Layout to avoid rebuild issues
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/auth/view_model/provider/keyboard_provider.dart';
import 'package:fluxfoot_seller/features/auth/views/widgets/signup_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

//! Separate Widget for Mobile Layout
class MobileSignUpLayout extends StatelessWidget {
  const MobileSignUpLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<KeyboardProvider>(
      builder: (context, keyboardProvider, child) {
        return SafeArea(
          child: Column(
            children: [
              // Fixed logo section
              SizedBox(
                height: keyboardProvider.isKeyboardVisible
                    ? 60
                    : size.height * 0.15,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: keyboardProvider.isKeyboardVisible
                      ? _buildMinimalLogo(size)
                      : _buildFullLogo(size),
                ),
              ),

              // Scrollable form content
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SignupForm(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullLogo(Size size) {
    return SingleChildScrollView(
      child: Column(
        key: const ValueKey('signup_full_logo'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo/logo.png',
            width: size.width * 0.2,
            height: size.height * 0.08,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 5),
          Text(
            'FLUXFOOT',
            style: GoogleFonts.rozhaOne(fontSize: size.width * 0.08),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalLogo(Size size) {
    return Center(
      key: const ValueKey('signup_minimal_logo'),
      child: Text(
        'FLUXFOOT',
        style: GoogleFonts.rozhaOne(fontSize: size.width * 0.06),
      ),
    );
  }
}



