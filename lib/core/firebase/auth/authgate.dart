import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/admin/presentation/screens/admin_waiting_banner_screen.dart';
import 'package:fluxfoot_seller/features/auth/views/screens/loging_screenn.dart';
import 'package:fluxfoot_seller/features/dashboard/presentation/screens/blocked_screen.dart';
import 'package:fluxfoot_seller/features/dashboard/presentation/screens/dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          // User is NOT logged in.
          return LoginScreen();
        } else {
          // User IS logged in. Check their seller status.
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('sellers')
                .doc(user.uid)
                .snapshots(),
            builder: (context, sellerSnapshot) {
              if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Safely check if the document exists and get the status
              final bool docExists = sellerSnapshot.data?.exists ?? false;
              final sellerData = sellerSnapshot.data?.data();

              // Default to 'unknown' if doc doesn't exist or status field is missing
              final status = sellerData?['status']?.toLowerCase() ?? 'unknown';

              if (!docExists ||
                  status == 'pending' ||
                  status == 'waiting' ||
                  status == 'unknown') {
                return AdminWaitingBannerScreen();
              }

              if (status == 'active' || status == 'approved') {
                return Dashboard(); 
              }

              // Handle blocked/rejected state
              if (status == 'blocked' || status == 'rejected') {
                return BlockedScreen(status: status);
              }

              return AdminWaitingBannerScreen();
            },
          );
        }
      },
    );
  }
}
