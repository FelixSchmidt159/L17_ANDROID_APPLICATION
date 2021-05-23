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
  double width = 0.0;

  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    super.didChangeDependencies();
  }

  bool showAvg = false;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
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
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).backgroundColor.withOpacity(0.6),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          width: width * 0.8,
          child: Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.40,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(18),
                      ),
                      color: Theme.of(context).accentColor),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 18.0, left: 12.0, top: 24, bottom: 12),
                    child: LineChart(
                      mainData(toursDocs),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            color: Colors.white,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.white,
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
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
            color: Colors.white,
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
          border: Border.all(color: Theme.of(context).accentColor, width: 1)),
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
}
