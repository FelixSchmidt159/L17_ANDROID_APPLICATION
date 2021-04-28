import 'package:flutter/material.dart';
import 'package:l17/screens/photo_screen.dart';
import 'package:provider/provider.dart';

import 'screens/overview_screen.dart';
import './providers/tours.dart';
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
          value: Tours(),
        ),
      ],
      child: MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.green,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: OverviewScreen(),
          routes: {
            PhotoScreen.routeName: (ctx) => PhotoScreen(),
            TourScreen.routeName: (ctx) => TourScreen(),
          }),
    );
  }
}
