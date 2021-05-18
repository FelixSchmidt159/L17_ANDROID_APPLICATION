import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:l17/screens/applicant_detail_screen.dart';
import 'package:l17/screens/auth_screen.dart';
import 'package:l17/screens/goal_screen.dart';
import 'package:l17/screens/photo_screen.dart';
import 'package:provider/provider.dart';

import 'providers/applicants.dart';
import 'models/mat_color.dart';
import 'screens/overview_screen.dart';
import 'screens/applicant_screen.dart';
import './screens/tour_screen.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // initializeDateFormatting('de');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MaterialColor mc = MatColor.createMaterialColor(Color(0xFF3b5998));
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
            primarySwatch: mc,
            backgroundColor: mc.shade900,
            accentColor: mc.shade900,
            iconTheme: IconThemeData(color: mc),
            accentColorBrightness: Brightness.dark,
            buttonTheme: ButtonTheme.of(context).copyWith(
              buttonColor: mc,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('de', 'DE'), // English, no country code
          ],
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
            ApplicantScreen.routeName: (ctx) => ApplicantScreen(),
            ApplicantDetailScreen.routeName: (ctx) => ApplicantDetailScreen(),
            GoalScreen.routeName: (ctx) => GoalScreen(),
          }),
    );
  }
}
