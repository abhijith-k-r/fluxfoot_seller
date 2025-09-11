import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/auth/presentation/provider/keyboard_provider.dart';
import 'package:fluxfoot_seller/features/auth/presentation/provider/signup_provider.dart';
import 'package:fluxfoot_seller/features/auth/presentation/widgets/singup_form.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignupProvider(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 768;
            return Consumer<KeyboardProvider>(
              builder: (context, keyboardprovider, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final mediaQuery = MediaQuery.of(context);
                  keyboardprovider.updateKeybaordState(
                    mediaQuery.viewInsets.bottom,
                  );
                });
                return Container(
                  child: isMobile ? const MobileSignUpLayout() : const WebSignUpLayout(),
                );
              },
            );
          },
        ),
      ),
    );
  } 
}
