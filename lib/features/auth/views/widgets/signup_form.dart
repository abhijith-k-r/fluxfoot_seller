import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';
import 'package:fluxfoot_seller/features/auth/view_model/provider/signup_provider.dart';
import 'package:fluxfoot_seller/features/auth/views/screens/loging_screenn.dart';
import 'package:fluxfoot_seller/features/auth/views/widgets/auth_checkbox_row.dart';
import 'package:fluxfoot_seller/features/auth/views/widgets/custom_textform.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
                      color: WebColors.iconGrey,
                    ),
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
                      color: WebColors.iconGrey,
                    ),
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
                        color: WebColors.iconGrey,
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
                      if (signupprovider.didAttemptSubmit &&
                          signupprovider.businessLicenseFileName.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            'Please upload your business license',
                            style: TextStyle(
                              color: WebColors.errorRed,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (signupprovider.businessLicenseFile != null ||
                          signupprovider.licenseFileBytes != null)
                        Stack(
                          alignment: AlignmentGeometry.topRight,
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: WebColors.bgWiteShade,
                                ),
                                image:
                                    signupprovider.businessLicenseFile != null
                                    ? DecorationImage(
                                        image: FileImage(
                                          signupprovider.businessLicenseFile!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : signupprovider.licenseFileBytes != null
                                    ? DecorationImage(
                                        image: MemoryImage(
                                          signupprovider.licenseFileBytes!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  signupprovider.clearBusinessLicense(),
                              icon: CircleAvatar(
                                backgroundColor: WebColors.iconGrey,
                                child: Icon(
                                  Icons.close,
                                  color: WebColors.iconWhite,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
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
                      color: WebColors.iconGrey,
                    ),
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
                      color: WebColors.iconGrey,
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
                      color: WebColors.iconGrey,
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
                    // Confirm password validator compares with the original password
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      if (value != signupprovider.passwordController.text) {
                        return 'Passwords do not match';
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
                      color: WebColors.iconGrey,
                    ),
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
                      color: WebColors.iconGrey,
                    ),
                    validator: (value) {
                      final trimmedValue = value?.trim();
                      if (trimmedValue == null || trimmedValue.isEmpty) {
                        return 'Please enter your warehouse location';
                      }
                      if (trimmedValue.length < 8) {
                        return 'Please provide a more detailed address';
                      }
                      if (!trimmedValue.contains(',') &&
                          !trimmedValue.contains('\n')) {
                        return 'Please include city or postcode (e.g. "Street, City")';
                      }
                      return null;
                    },
                  ),

                  // ! agree to the terms and conditions
                  AuthCheckBox(
                    mainAxis: MainAxisAlignment.center,
                    checkBox: Checkbox(
                      value: signupprovider.rememberMe,
                      activeColor: WebColors.activeOrange,
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
                          color: WebColors.textBlack,
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
                        backgroundColor: WebColors.buttonPurple,
                        foregroundColor: WebColors.textWite,
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
                          color: WebColors.textBlue,
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
