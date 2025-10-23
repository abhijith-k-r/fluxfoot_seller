import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';

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

// ! Fade Push ReplaceMent
void fadePUshReplaceMent(BuildContext context, Widget page) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

// ! Fade push And RemoveUntil
void fadePushAndRemoveUntil(BuildContext context, Widget page) {
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
    (Route<dynamic> route) => false,
  );
}

// ! Custom SnackBar
void showOverlaySnackbar(BuildContext context, String message, Color color) {
  // Use a GlobalKey to access the Scaffold's Overlay
  OverlayState? overlay;

  // Rebuild the widget tree to ensure Overlay is available
  void rebuildWithOverlay() {
    overlay = Overlay.of(context);
    if (overlay == null) {
      // Schedule a microtask to retry after the frame
      Future.microtask(() => rebuildWithOverlay());
      return;
    }

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: WebColors.iconWhite, size: 16),
                SizedBox(width: 10),
                Text(message, style: TextStyle(color: WebColors.textWite)),
                SizedBox(width: 30),
                IconButton(
                  icon: Icon(Icons.close, color: WebColors.iconWhite, size: 15),
                  onPressed: () {
                    overlayEntry.remove();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay!.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  rebuildWithOverlay();
}
