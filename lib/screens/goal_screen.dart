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

  bool showAvg = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fortschritt'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 120,
          ),
          LineChartWidget(),
        ],
      ),
    );
  }
}
