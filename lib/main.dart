import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/screens/auth/login.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:kajur_app/screens/auth/register.dart';
import 'package:kajur_app/screens/home.dart';
import 'package:kajur_app/screens/splash_screen/splash_screen.dart';
import 'firebase_options.dart';
import 'design/system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kajur",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: DesignSystem.blackColor,
        primaryColor: DesignSystem.purpleAccent,
        appBarTheme: const AppBarTheme(
            color: DesignSystem.blackColor, foregroundColor: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                backgroundColor: DesignSystem.purpleAccent,
                foregroundColor: Colors.white)),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: DesignSystem.greyColor.withOpacity(.50),
              )),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
        ),
      ),
      routes: {
        '/': (context) => SplashScreen(
              // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
              child: LoginPage(),
            ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/list_produk': (context) => ListProdukPage(),
      },
    );
  }
}
