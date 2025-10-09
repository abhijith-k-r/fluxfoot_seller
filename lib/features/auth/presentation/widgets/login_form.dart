// Separate Widget for Mobile Layout to avoid rebuild issues
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/auth/presentation/provider/keyboard_provider.dart';
import 'package:fluxfoot_seller/features/auth/presentation/provider/login_provider.dart';
import 'package:fluxfoot_seller/features/auth/presentation/screens/signup_screen.dart';
import 'package:fluxfoot_seller/features/auth/presentation/widgets/singup_form.dart';
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
                  // Logo section with smooth animations
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
                              color: Colors.black,
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

// ! Texting Layout



// Separate LoginForm Widget
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Consumer<LoginProvider>(
      builder: (context, loginprovider, child) {
        return Form(
          key: loginprovider.loginFormKey,
          child: Padding(
            padding: EdgeInsets.only(right: !isMobile ? 30 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? size.width * 0.07 : size.width * 0.03,
                  ),
                ),

                Text(
                  'Log in to your seller account',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w400,
                    fontSize: isMobile ? size.width * 0.03 : size.width * 0.01,
                  ),
                ),
                SizedBox(height: 24),

                //! Email Field
                CustomTextFormField(
                  label: 'Enter Email',
                  hintText: 'example@fluxfoot.com',
                  controller: loginprovider.emailController,
                  focusNode: loginprovider.emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefIcon: Icon(
                    Icons.email,
                    size: isMobile ? 24 : 20,
                    color: Colors.grey.shade400,
                  ),
                  onFieldSubmitted: (_) {
                    FocusScope.of(
                      context,
                    ).requestFocus(loginprovider.passwordFocus);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                //! Password Field
                CustomTextFormField(
                  label: 'Enter Password',
                  hintText: '••••••••',
                  controller: loginprovider.passwordController,
                  focusNode: loginprovider.passwordFocus,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  obscureText: !loginprovider.isPasswordVisible,
                  prefIcon: Icon(
                    Icons.lock,
                    size: isMobile ? 24 : 20,
                    color: Colors.grey.shade400,
                  ),
                  suffIcon: IconButton(
                    onPressed: loginprovider.isLoading
                        ? null
                        : loginprovider.togglePasswordVisible,
                    icon: Icon(
                      loginprovider.isPasswordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                  onFieldSubmitted: (_) => loginprovider.handleLoging(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // ! acuth Check Box
                AuthCheckBox(
                  mainAxis: MainAxisAlignment.spaceBetween,
                  checkBox: Checkbox(
                    value: loginprovider.rememberMe,
                    activeColor: Colors.orange,
                    onChanged: loginprovider.isLoading
                        ? null
                        : loginprovider.toggleRememberMe,
                  ),
                  prefText: 'Remember me',
                  sufWidget: TextButton(
                    onPressed: loginprovider.isLoading
                        ? null
                        : () => loginprovider.handleForgotPassword(context),
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loginprovider.isLoading
                        ? null
                        : () => loginprovider.handleLoging(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4B5EFC),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.openSans(
                        fontSize: isMobile ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                AuthCheckBox(
                  mainAxis: MainAxisAlignment.center,
                  prefText: 'New Seller?',
                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                  sufWidget: TextButton(
                    onPressed: () {
                      fadePush(context, SignupScreen());
                    },
                    child: Text(
                      'Sign up here',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),

                // ! Secure login static
                SizedBox(height: 10),
                AuthCheckBox(
                  mainAxis: MainAxisAlignment.center,
                  checkBox: Icon(Icons.lock, size: 20),
                  prefText: 'Secure login?',
                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Custom Text Form Field
class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final Widget? prefIcon;
  final Widget? suffIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final bool? enabled;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefIcon,
    this.suffIcon,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: isMobile ? 14 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          enabled: enabled,
          onFieldSubmitted: onFieldSubmitted,
          style: GoogleFonts.openSans(fontSize: isMobile ? 16 : 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.openSans(
              color: Colors.grey.shade400,
              fontSize: isMobile ? 16 : 14,
            ),
            prefixIcon: prefIcon,
            suffixIcon: suffIcon,
            fillColor: Color(0xFFE0E0E0),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orangeAccent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

// ! auth Check Box

class AuthCheckBox extends StatelessWidget {
  final MainAxisAlignment mainAxis;
  final Widget? checkBox;
  final String prefText;
  final TextButton? sufWidget;
  final TextStyle? style;
  const AuthCheckBox({
    super.key,
    required this.mainAxis,
    this.checkBox,
    required this.prefText,
    this.sufWidget,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxis,
      children: [
        Row(
          children: [
            if (checkBox != null) checkBox!,
            Text(prefText, style: style),
          ],
        ),
        if (sufWidget != null) sufWidget!,
      ],
    );
  }
}
