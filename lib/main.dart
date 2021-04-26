import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/overview_screen.dart';
import './providers/tours.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
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
            // ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          }),
    );
  }
}
