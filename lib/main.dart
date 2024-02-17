import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kajur_app/screens/splash_screen/splash_screen_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'firebase_options.dart';
import 'design/system.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/home/home_page.dart';
import 'screens/products/tambah produk/add_products_page.dart';
import 'screens/products/list/list_products_page.dart';
import 'components/comingsoon/comingsoon.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  timeago.setLocaleMessages('id', timeago.IdMessages());
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );

  initializeDateFormatting('id', null).then((_) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String signUpRoute = '/signUp';
  static const String homeRoute = '/home';
  static const String listProdukRoute = '/list_produk';
  static const String addProdukRoute = '/add_produk';
  static const String comingSoonRoute = '/comingsoon';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('id'), // Spanish
      ],
      debugShowCheckedModeBanner: false,
      theme: buildTheme(context),
      initialRoute: initialRoute,
      routes: {
        initialRoute: (context) => const SplashScreen(
              child: LoginPage(),
            ),
        loginRoute: (context) => const LoginPage(),
        signUpRoute: (context) => const SignUpPage(),
        homeRoute: (context) => const HomePage(),
        listProdukRoute: (context) => const ListProdukPage(),
        addProdukRoute: (context) => const AddDataPage(),
        comingSoonRoute: (context) => const ComingSoonPage(),
      },
    );
  }

  ThemeData buildTheme(BuildContext context) {
    return ThemeData(
      indicatorColor: Col.primaryColor,
      textTheme: GoogleFonts.nunitoSansTextTheme(
        Theme.of(context).textTheme,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: Col.backgroundColor,
      primaryColor: Col.primaryColor,
      dialogBackgroundColor: Col.backgroundColor,
      iconTheme: const IconThemeData(color: Col.blackColor),
      appBarTheme: const AppBarTheme(
        foregroundColor: Col.blackColor,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Col.secondaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              backgroundColor: Col.primaryColor,
              foregroundColor: Col.backgroundColor)),
      inputDecorationTheme: InputDecorationTheme(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Col.greyColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Col.primaryColor, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Col.redAccent, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Col.redAccent, width: 1),
          )),
      colorScheme: const ColorScheme(
        primary: Col.primaryColor,
        secondary: Col.secondaryColor,
        background: Col.backgroundColor,
        surface: Col.secondaryColor,
        onBackground: Colors.black,
        onSurface: Colors.black,
        onError: Colors.white,
        onPrimary: Col.secondaryColor,
        onSecondary: Colors.black,
        brightness: Brightness.light,
        error: Colors.red,
      ),
    );
  }
}
