import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/comingsoon/comingsoon.dart';
import 'package:kajur_app/screens/auth/login.dart';
import 'package:kajur_app/screens/products/add_products.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:kajur_app/screens/auth/register.dart';
import 'package:kajur_app/screens/home/home.dart';
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
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        indicatorColor: DesignSystem.primaryColor,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: DesignSystem.backgroundColor,
        primaryColor: DesignSystem.primaryColor,
        dialogBackgroundColor: DesignSystem.backgroundColor,
        iconTheme: const IconThemeData(color: DesignSystem.blackColor),
        appBarTheme: const AppBarTheme(
          foregroundColor: DesignSystem.blackColor,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: DesignSystem.secondaryColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                backgroundColor: DesignSystem.primaryColor,
                foregroundColor: DesignSystem.backgroundColor)),
        inputDecorationTheme: InputDecorationTheme(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  const BorderSide(color: DesignSystem.greyColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  const BorderSide(color: DesignSystem.primaryColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  const BorderSide(color: DesignSystem.redAccent, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  const BorderSide(color: DesignSystem.redAccent, width: 1),
            )),
        colorScheme: const ColorScheme(
          primary: DesignSystem.primaryColor,
          secondary: DesignSystem.secondaryColor,
          background: DesignSystem.backgroundColor,
          surface: DesignSystem.secondaryColor,
          onBackground: Colors.black,
          onSurface: Colors.black,
          onError: Colors.white,
          onPrimary: DesignSystem.secondaryColor,
          onSecondary: Colors.black,
          brightness: Brightness.light,
          error: Colors.red,
        ),
      ),
      routes: {
        '/': (context) => const SplashScreen(
              child: LoginPage(),
            ),
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/list_produk': (context) => const ListProdukPage(),
        '/add_produk': (context) => const AddDataPage(),
        '/comingsoon': (context) => const ComingSoonPage(),
      },
    );
  }
}
