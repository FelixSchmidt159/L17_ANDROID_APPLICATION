import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:l17/providers/applicants.dart';
import 'package:provider/provider.dart';

class LineChartWidget extends StatefulWidget {
  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  String _selectedDriver;
  final currentUser = FirebaseAuth.instance.currentUser;

  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    super.didChangeDependencies();
  }

  void prepareData(dynamic toursSnapshot) {}

  bool showAvg = false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (ctx, toursSnapshot) {
        if (toursSnapshot.connectionState == ConnectionState.waiting &&
            _selectedDriver != null) {
          return Container(
            // height: widget.height * 0.90,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final toursDocs = toursSnapshot.data.docs;
        return Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.70,
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                    color: Color(0xff232d37)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 18.0, left: 12.0, top: 24, bottom: 12),
                  child: LineChart(
                    mainData(toursDocs),
                  ),
                ),
              ),
            ),
            // SizedBox(
            //   width: 60,
            //   height: 34,
            //   child: Text(
            //     '[km]',
            //     style: TextStyle(fontSize: 12, color: Colors.white),
            //   ),
            // ),
          ],
        );
      },
    );
  }

  LineChartData mainData(dynamic data) {
    List<FlSpot> graphData = [];
    // var hi = DateTime.now();

    var arr = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    for (int i = 0; i < data.length; i++) {
      arr[DateTime.fromMicrosecondsSinceEpoch(
                  data[i]['timestamp'].microsecondsSinceEpoch)
              .month -
          1] += data[i]['distance'];
    }
    for (int i = 1; i < 12; i++) {
      arr[i] += arr[i - 1];
    }
    for (int i = 0; i < DateTime.now().month; i++) {
      graphData.add(FlSpot((i.toDouble()), arr[i].toDouble() / 500));
    }
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return 'Jän';
              case 2:
                return 'Mär';
              case 4:
                return 'Mai';
              case 6:
                return 'Jul';
              case 8:
                return 'Sep';
              case 10:
                return 'Nov';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '500';
              case 2:
                return '1000';
              case 3:
                return '1500';
              case 4:
                return '2000';
              case 5:
                return '2500';
              case 6:
                return '3000';
              case 7:
                return '[km]';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 13,
      minY: 0,
      maxY: 7,
      lineBarsData: [
        LineChartBarData(
          spots: graphData,
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  // LineChartData avgData() {
  //   return LineChartData(
  //     lineTouchData: LineTouchData(enabled: false),
  //     gridData: FlGridData(
  //       show: true,
  //       drawHorizontalLine: true,
  //       getDrawingVerticalLine: (value) {
  //         return FlLine(
  //           color: const Color(0xff37434d),
  //           strokeWidth: 1,
  //         );
  //       },
  //       getDrawingHorizontalLine: (value) {
  //         return FlLine(
  //           color: const Color(0xff37434d),
  //           strokeWidth: 1,
  //         );
  //       },
  //     ),
  //     titlesData: FlTitlesData(
  //       show: true,
  //       bottomTitles: SideTitles(
  //         showTitles: true,
  //         reservedSize: 22,
  //         getTextStyles: (value) => const TextStyle(
  //             color: Color(0xff68737d),
  //             fontWeight: FontWeight.bold,
  //             fontSize: 16),
  //         getTitles: (value) {
  //           switch (value.toInt()) {
  //             case 1:
  //               return 'Jan';
  //             case 5:
  //               return 'Jun';
  //             case 12:
  //               return 'Dez';
  //           }
  //           return '';
  //         },
  //         margin: 8,
  //       ),
  //       leftTitles: SideTitles(
  //         showTitles: true,
  //         getTextStyles: (value) => const TextStyle(
  //           color: Color(0xff67727d),
  //           fontWeight: FontWeight.bold,
  //           fontSize: 15,
  //         ),
  //         getTitles: (value) {
  //           switch (value.toInt()) {
  //             case 1:
  //               return '100km';
  //             case 3:
  //               return '300km';
  //             case 5:
  //               return '400km';
  //           }
  //           return '';
  //         },
  //         reservedSize: 28,
  //         margin: 12,
  //       ),
  //     ),
  //     borderData: FlBorderData(
  //         show: true,
  //         border: Border.all(color: const Color(0xff37434d), width: 1)),
  //     minX: 0,
  //     maxX: 11,
  //     minY: 0,
  //     maxY: 6,
  //     lineBarsData: [
  //       LineChartBarData(
  //         spots: [
  //           FlSpot(0, 3.44),
  //           FlSpot(2.6, 3.44),
  //           FlSpot(4.9, 3.44),
  //           FlSpot(6.8, 3.44),
  //           FlSpot(8, 3.44),
  //           FlSpot(9.5, 3.44),
  //           FlSpot(11, 3.44),
  //         ],
  //         isCurved: true,
  //         colors: [
  //           ColorTween(begin: gradientColors[0], end: gradientColors[1])
  //               .lerp(0.2),
  //           ColorTween(begin: gradientColors[0], end: gradientColors[1])
  //               .lerp(0.2),
  //         ],
  //         barWidth: 5,
  //         isStrokeCapRound: true,
  //         dotData: FlDotData(
  //           show: false,
  //         ),
  //         belowBarData: BarAreaData(show: true, colors: [
  //           ColorTween(begin: gradientColors[0], end: gradientColors[1])
  //               .lerp(0.2)
  //               .withOpacity(0.1),
  //           ColorTween(begin: gradientColors[0], end: gradientColors[1])
  //               .lerp(0.2)
  //               .withOpacity(0.1),
  //         ]),
  //       ),
  //     ],
  //   );
  // }
}
