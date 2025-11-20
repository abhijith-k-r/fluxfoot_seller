import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/firebase/auth/authgate.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 7), () {
      if (mounted) fadePUshReplaceMent(context, AuthGate());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            WebColors.borderSideOrange,
            BlendMode.srcATop,
          ),
          child: Lottie.asset('assets/lotties/Untitled file.json'),
        ),
      ),
    );
  }
}