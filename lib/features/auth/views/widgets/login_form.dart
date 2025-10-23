import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';
import 'package:fluxfoot_seller/features/auth/view_model/provider/login_provider.dart';
import 'package:fluxfoot_seller/features/auth/views/screens/signup_screen.dart';
import 'package:fluxfoot_seller/features/auth/views/widgets/auth_checkbox_row.dart';
import 'package:fluxfoot_seller/features/auth/views/widgets/custom_textform.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

//! Separate LoginForm Widget
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
                    color: WebColors.iconGrey,
                  ),
                  onFieldSubmitted: (_) {
                    FocusScope.of(
                      context,
                    ).requestFocus(loginprovider.passwordFocus);
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
                    color: WebColors.iconGrey,
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
                ),
                SizedBox(height: 20),
                // ! acuth Check Box
                AuthCheckBox(
                  mainAxis: MainAxisAlignment.spaceBetween,
                  checkBox: Checkbox(
                    value: loginprovider.rememberMe,
                    activeColor: WebColors.activeOrange,
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
                        color: WebColors.textBlack,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                // !Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loginprovider.isLoading
                        ? null
                        : () => loginprovider.handleLoging(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WebColors.buttonPurple,
                      foregroundColor: WebColors.textWite,
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
                        color: WebColors.textBlue,
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
