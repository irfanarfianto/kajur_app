import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;

  const SplashScreen({Key? key, this.child}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => widget.child!),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          // You can adjust the image properties here
          image: DecorationImage(
            image: AssetImage('images/splash.png'),
            fit: BoxFit.cover, // Adjust the BoxFit as needed
          ),
        ),
        child: Center(
            // You can add additional widgets over the image if required
            // Example: CircularProgressIndicator(), Text(), etc.
            ),
      ),
    );
  }
}
