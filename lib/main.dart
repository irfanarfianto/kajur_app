import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/comingsoon/comingsoon.dart';
import 'package:kajur_app/screens/auth/login.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:kajur_app/screens/auth/register.dart';
import 'package:kajur_app/screens/home.dart';
import 'package:kajur_app/screens/splash_screen/splash_screen.dart';
import 'firebase_options.dart';
import 'design/system.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  timeago.setLocaleMessages('id', timeago.IdMessages());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting('id', null).then((_) {
    // Jalankan aplikasi Flutter
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kajur",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        scaffoldBackgroundColor: DesignSystem.backgroundColor,
        primaryColor: DesignSystem.primaryColor,
        dialogBackgroundColor: DesignSystem.backgroundColor,
        appBarTheme: const AppBarTheme(
          color: DesignSystem.backgroundColor,
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                backgroundColor: DesignSystem.primaryColor,
                foregroundColor: DesignSystem.backgroundColor)),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: DesignSystem.primaryColor, width: 1),
          ),
        ),
      ),
      routes: {
        '/': (context) => SplashScreen(
              child: LoginPage(),
            ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/list_produk': (context) => ListProdukPage(),
        '/comingsoon': (context) => ComingSoonPage(),
      },
    );
  }
}
