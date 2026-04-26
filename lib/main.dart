import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/auth/view_model/provider/keyboard_provider.dart';
import 'package:fluxfoot_seller/features/auth/views/screens/splash_screen.dart';
import 'package:fluxfoot_seller/features/chat/view_model/chat_provider.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/sidemenu/view_model/provider/drop_down_btn_provider.dart';
import 'package:fluxfoot_seller/features/sidemenu/view_model/provider/side_menu_provider.dart';
import 'package:fluxfoot_seller/features/dashboard/view_model/provider/dashboard_provider.dart';
import 'package:fluxfoot_seller/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    log(e.toString());
  }
  runApp(const MYApp());
}

class MYApp extends StatelessWidget {
  const MYApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<KeyboardProvider>(
          create: (context) => KeyboardProvider(),
        ),
        ChangeNotifierProvider<SideMenuProvider>(
          create: (context) => SideMenuProvider(),
        ),
        ChangeNotifierProvider<DropDownButtonProvider>(
          create: (context) => DropDownButtonProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DashboardProvider(),
        ),
         ChangeNotifierProvider<SellerChatProvider>(
          create: (context) => SellerChatProvider(),
        ),
      ],

      child: MaterialApp(
        title: 'FluxFoot_Seller',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
