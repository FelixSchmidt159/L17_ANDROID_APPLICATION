import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/screens/auth_screen.dart';
import 'package:l17/screens/photo_screen.dart';
import 'package:l17/screens/crop_image_screen.dart';
import 'package:provider/provider.dart';

import 'providers/applicants.dart';
import 'screens/overview_screen.dart';
import './screens/tour_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Applicants(),
        ),
      ],
      child: MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            // primarySwatch: Colors.green,
            // accentColor: Colors.deepOrange,
            // fontFamily: 'Lato',
            primarySwatch: Colors.pink,
            backgroundColor: Colors.pink,
            accentColor: Colors.deepPurple,
            accentColorBrightness: Brightness.dark,
            buttonTheme: ButtonTheme.of(context).copyWith(
              buttonColor: Colors.pink,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, userSnapshot) {
              if (userSnapshot.hasData) {
                return OverviewScreen();
              }
              return AuthScreen();
            },
          ),
          routes: {
            PhotoScreen.routeName: (ctx) => PhotoScreen(),
            TourScreen.routeName: (ctx) => TourScreen(),
            CropImageScreen.routeName: (ctx) => CropImageScreen(),
          }),
    );
  }
}
