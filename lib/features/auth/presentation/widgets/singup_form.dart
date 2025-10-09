// Separate Widget for Mobile Layout to avoid rebuild issues
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/auth/presentation/provider/keyboard_provider.dart';
import 'package:fluxfoot_seller/features/auth/presentation/provider/signup_provider.dart';
import 'package:fluxfoot_seller/features/auth/presentation/screens/loging_screenn.dart';
import 'package:fluxfoot_seller/features/auth/presentation/widgets/login_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WebSignUpLayout extends StatelessWidget {
  const WebSignUpLayout({super.key});

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
        Expanded(child: Center(child: SignupForm())),
      ],
    );
  }
}

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

//! Separate SignUPForm Widget
class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Consumer<SignupProvider>(
      builder: (context, signupprovider, child) {
        return Form(
          key: signupprovider.signupFormkey,
          child: Padding(
            padding: EdgeInsets.only(right: !isMobile ? 30 : 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Join as a Seller',
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile
                          ? size.width * 0.07
                          : size.width * 0.03,
                    ),
                  ),

                  Text(
                    'Start your journey with us today',
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w400,
                      fontSize: isMobile
                          ? size.width * 0.03
                          : size.width * 0.01,
                    ),
                  ),
                  SizedBox(height: 24),

                  // !Seller Name Field
                  CustomTextFormField(
                    label: 'Enter Name',
                    hintText: 'Marcus Rashford',
                    controller: signupprovider.nameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    prefIcon: Icon(
                      Icons.person,
                      size: isMobile ? 24 : 20,
                      color: Colors.grey.shade400,
                    ),

                    validator: (value) {
                      final trimmedValue = value?.trim();

                      if (trimmedValue == null || trimmedValue.isEmpty) {
                        return 'Please enter your Name';
                      }
                      if (!RegExp(r"^[a-zA-Z\s.-]+$").hasMatch(trimmedValue)) {
                        return 'Name can only contain letters, spaces, hyphens, or periods.';
                      }
                      if (trimmedValue.length < 2) {
                        return 'Name must be at least 2 characters long.';
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 24),

                  // !Store Name Field (NEW)
                  CustomTextFormField(
                    label: 'Store Name (Public Facing)',
                    hintText: 'The Kit Depot',
                    controller: signupprovider.storeNameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    prefIcon: Icon(
                      Icons.store,
                      size: isMobile ? 24 : 20,
                      color: Colors.grey.shade400,
                    ),
                    validator: (value) {
                      final trimmedValue = value?.trim();
                      if (trimmedValue == null || trimmedValue.isEmpty) {
                        return 'Please enter your public Store Name';
                      }
                      if (trimmedValue.length < 3) {
                        return 'Store Name must be at least 3 characters long.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // !Business Type Dropdown (NEW)
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Business Type',
                      hintText: 'Select business structure',
                      prefixIcon: Icon(
                        Icons.business,
                        size: isMobile ? 24 : 20,
                        color: Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: signupprovider.selectedBusinessType.isEmpty
                            ? null
                            : signupprovider.selectedBusinessType,
                        hint: Text('Select Business Type'),
                        items: signupprovider.businessTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: signupprovider.isLoading
                            ? null
                            : (String? newValue) {
                                signupprovider.setSelectedBusinessType(
                                  newValue ?? '',
                                );
                              },
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // !Business License Document Upload (NEW FIELD) 📄
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business License Upload',
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: signupprovider.isLoading
                            ? null
                            : () => signupprovider.pickBusinessLicense(context),
                        icon: Icon(Icons.cloud_upload),
                        label: Text(
                          signupprovider.businessLicenseFileName.isEmpty
                              ? 'Select Business License (PDF/JPG)'
                              : 'Change File: ${signupprovider.businessLicenseFileName}',
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (signupprovider.signupFormkey.currentState
                                  ?.validate() ==
                              false &&
                          signupprovider.businessLicenseFileName.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            'Please upload your business license',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // !Email Field
                  CustomTextFormField(
                    label: 'Enter Email',
                    hintText: 'example@fluxfoot.com',
                    controller: signupprovider.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefIcon: Icon(
                      Icons.email,
                      size: isMobile ? 24 : 20,
                      color: Colors.grey.shade400,
                    ),

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

                  //! Enter Password
                  CustomTextFormField(
                    label: 'Create Password',
                    hintText: '••••••••',
                    controller: signupprovider.passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    obscureText: !signupprovider.isEnterPasswordVisible,
                    prefIcon: Icon(
                      Icons.lock,
                      size: isMobile ? 24 : 20,
                      color: Colors.grey.shade400,
                    ),
                    suffIcon: IconButton(
                      onPressed: signupprovider.isLoading
                          ? null
                          : signupprovider.togglePasswordVisibleEnter,
                      icon: Icon(
                        signupprovider.isEnterPasswordVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                    ),

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

                  // !Confirm password
                  CustomTextFormField(
                    label: 'Confirm Password',
                    hintText: '••••••••',
                    controller: signupprovider.confirmPassController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    obscureText: !signupprovider.isCreatePasswordVisible,
                    // enabled: !signupprovider.isLoading,
                    prefIcon: Icon(
                      Icons.lock,
                      size: isMobile ? 24 : 20,
                      color: Colors.grey.shade400,
                    ),
                    suffIcon: IconButton(
                      onPressed: signupprovider.isLoading
                          ? null
                          : signupprovider.togglePasswordVisibleCreate,
                      icon: Icon(
                        signupprovider.isCreatePasswordVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                    ),
                    // onFieldSubmitted: (_) => _handleLogin(),
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

                  //! Phone Number
                  CustomTextFormField(
                    label: 'Phone Number',
                    hintText: '+91 (000) 00-0000',
                    controller: signupprovider.phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    prefIcon: Icon(
                      Icons.phone,
                      size: isMobile ? 24 : 20,
                      color: Colors.grey.shade400,
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Phone Number';
                      }
                      if (value.length < 10) {
                        return 'Number must be at least 10 Numbers';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20),
                  // !Warehouse Address / Shipping Origin (NEW)
                  CustomTextFormField(
                    label: 'Warehouse/Shipping Origin Address',
                    hintText: '123 Stadium Rd, Manchester',
                    controller: signupprovider.warehouseController,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.done,
                    prefIcon: Icon(
                      Icons.location_on,
                      size: isMobile ? 24 : 20,
                      color: Colors.grey.shade400,
                    ),
                    validator: (value) {
                      final trimmedValue = value?.trim();
                      if (trimmedValue == null || trimmedValue.isEmpty) {
                        return 'Please enter your warehouse location';
                      }
                      return null;
                    },
                  ),

                  // ! agree to the terms and conditions
                  AuthCheckBox(
                    mainAxis: MainAxisAlignment.center,
                    checkBox: Checkbox(
                      value: signupprovider.rememberMe,
                      activeColor: Colors.orange,
                      onChanged: signupprovider.isLoading
                          ? null
                          : signupprovider.toggleRemember,
                    ),
                    prefText: 'I agree to the ',
                    sufWidget: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Terms and Conditions',
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  //! signUp Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: signupprovider.isLoading
                          ? null
                          : () => signupprovider.handleSignup(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4B5EFC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Sign Up',
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
                    prefText: 'Already have an account?',
                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                    sufWidget: TextButton(
                      onPressed: () {
                        fadePush(context, LoginScreen());
                      },
                      child: Text(
                        'Login',
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ! Fade Push

void fadePush(BuildContext context, Widget page) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
