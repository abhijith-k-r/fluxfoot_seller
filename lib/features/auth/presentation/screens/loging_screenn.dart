// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/auth/presentation/provider/keyboard_provider.dart';
import 'package:fluxfoot_seller/features/auth/presentation/provider/login_provider.dart';
import 'package:fluxfoot_seller/features/auth/presentation/widgets/login_form.dart';
import 'package:fluxfoot_seller/features/auth/presentation/widgets/web_login_form.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginProvider(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 768;
            return Consumer<KeyboardProvider>(
              builder: (context, KeyboardProvider, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final mediaQuery = MediaQuery.of(context);
                  KeyboardProvider.updateKeybaordState(
                    mediaQuery.viewInsets.bottom,
                  );
                });
                return Container(
                  // ! It will show based on the Screen size
                  child: isMobile ? MobileLoginLayout() : WebLoginLayout(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
