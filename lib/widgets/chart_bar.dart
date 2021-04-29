import 'package:flutter/material.dart';

class ChartBar extends StatelessWidget {
  int distanceDriven;
  int distanceGoal;
  final double height;

  ChartBar(this.distanceDriven, this.distanceGoal, this.height);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (distanceDriven >= distanceGoal) {
      distanceDriven = distanceGoal;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: height * 0.25,
          width: width * 0.3,
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  color: Color.fromRGBO(220, 220, 220, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: distanceDriven / distanceGoal,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
