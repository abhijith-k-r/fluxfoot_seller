// Separate Widget for Mobile Layout to avoid rebuild issues
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/features/auth/view_model/provider/keyboard_provider.dart';
import 'package:fluxfoot_seller/features/auth/views/widgets/login_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MobileLoginLayout extends StatelessWidget {
  const MobileLoginLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<KeyboardProvider>(
      builder: (context, keyboardprovider, child) {
        return SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: keyboardprovider.isKeyboardVisible
                  ? keyboardprovider.keyboardHeight + 20
                  : 20,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  //! Logo section with smooth animations
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: keyboardprovider.isKeyboardVisible
                        ? 60
                        : size.height * 0.2,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: keyboardprovider.isKeyboardVisible
                                ? 0.0
                                : 1.0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: keyboardprovider.isKeyboardVisible
                                  ? 0
                                  : size.height * 0.12,
                              child: keyboardprovider.isKeyboardVisible
                                  ? const SizedBox.shrink()
                                  : Image.asset(
                                      'assets/logo/logo.png',
                                      width: size.width * 0.25,
                                      height: size.height * 0.12,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                          if (!keyboardprovider.isKeyboardVisible)
                            const SizedBox(height: 5),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: GoogleFonts.rozhaOne(
                              fontSize: keyboardprovider.isKeyboardVisible
                                  ? size.width * 0.06
                                  : size.width * 0.08,
                              color: WebColors.textBlack,
                            ),
                            child: Text('FLUXFOOT'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: keyboardprovider.isKeyboardVisible ? 10 : 20,
                  ),
                  //! Login form
                  LoginForm(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
