import 'package:flutter/material.dart';

class AdminWaitingBannerScreen extends StatelessWidget {
  const AdminWaitingBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Container(
          width: size * 0.8,
          height: size * 0.05,
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
      ),
    );
  }
}
