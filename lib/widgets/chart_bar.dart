import 'package:flutter/material.dart';

class ChartBar extends StatelessWidget {
  final int distanceDriven;
  final int distanceGoal;
  final double height;
  final double width;

  ChartBar(this.distanceDriven, this.distanceGoal, this.height, this.width);

  @override
  Widget build(BuildContext context) {
    return distanceDriven != 0
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: height,
                width: width,
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0),
                        color: Color.fromRGBO(220, 220, 220, 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: distanceDriven / distanceGoal <= 1.0
                          ? distanceDriven / distanceGoal
                          : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }
}
