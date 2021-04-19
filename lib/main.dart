import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/tours_overview_screen.dart';
import './providers/tours.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
          home: ToursOverviewScreen(),
          routes: {
            // ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          }),
    );
  }
}
