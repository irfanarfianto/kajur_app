import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

class ComingSoonPage extends StatefulWidget {
  const ComingSoonPage({Key? key}) : super(key: key);

  @override
  _ComingSoonPageState createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage> {
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Col.secondaryColor,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'images/roket.gif',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 280, // Adjust the height as needed
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Col.primaryColor.withOpacity(0.9),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _currentUser != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nongki bentar ya, ${_currentUser!.displayName}! Bakal ada update seru nih!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Col.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'See you..',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Col.secondaryColor,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 55,
            right: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close,
                  color: Col.secondaryColor, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
