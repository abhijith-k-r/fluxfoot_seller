import 'package:flutter/material.dart';

class AdminWaitingBannerScreen extends StatelessWidget {
  const AdminWaitingBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 768;
          return Container(
            child: isMobile
                ? MobileWaitingBannerScreen(size: size)
                : WebWaitingBannerScreen(size: size),
          );
        },
      ),
    );
  }
}

class MobileWaitingBannerScreen extends StatelessWidget {
  const MobileWaitingBannerScreen({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size * 0.8,
        height: size * 0.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: size * 0.02, right: size * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Your account is awaiting approval by the administrator.',
                  ),
                  Text("We will notify you once it's approved."),
                ],
              ),
              TextButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF4B5EFC)),
                ),
                onPressed: () {},
                child: Text('Contact Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebWaitingBannerScreen extends StatelessWidget {
  const WebWaitingBannerScreen({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size * 0.8,
        height: 80,
        // size * 0.05,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: size * 0.02, right: size * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your account is awaiting approval by the administrator.',
                  ),
                  Text("We will notify you once it's approved."),
                ],
              ),
              TextButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF4B5EFC)),
                ),
                onPressed: () {},
                child: Text('Contact Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
