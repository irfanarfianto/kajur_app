import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kajur_app/components/comingsoon/comingsoon.dart';
import 'package:kajur_app/firebase_options.dart';
import 'package:kajur_app/screens/auth/login_page.dart';
import 'package:kajur_app/screens/auth/register_page.dart';
import 'package:kajur_app/screens/home/home_page.dart';
import 'package:kajur_app/screens/products/list/list_products_page.dart';
import 'package:kajur_app/screens/products/tambah%20produk/add_products_page.dart';
import 'package:kajur_app/screens/splash_screen/splash_screen_page.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:timeago/timeago.dart' as timeago;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFlutterNotifications();
  showFlutterNotification(message);
  print('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'launcher_notification',
        ),
      ),
    );
    navigatorKey.currentState?.pushNamed(MyApp.listProdukRoute);
  }
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  timeago.setLocaleMessages('id', timeago.IdMessages());
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    // Menampilkan notifikasi saat aplikasi berjalan di foreground
    showFlutterNotification(message);
    print('Handling a foreground message ${message.messageId}');

    // Menavigasi pengguna ke layar tertentu
  });

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
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
              // padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
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
        surface: Col.secondaryColor,
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
