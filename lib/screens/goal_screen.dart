import 'package:flutter/material.dart';

import 'package:l17/widgets/line_chart.dart';

class GoalScreen extends StatefulWidget {
  static const routeName = '/goal-screen';
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  double width = 0.0;

  bool showAvg = false;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Fortschritt'),
      ),
      body: Container(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
            ),
            LineChartWidget(),
          ],
        ),
      ),
    );
  }
}
