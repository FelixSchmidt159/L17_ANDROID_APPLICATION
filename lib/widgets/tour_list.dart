import 'package:flutter/material.dart';
import 'package:l17/providers/tour.dart';
import 'package:l17/providers/tours.dart';
import 'package:l17/widgets/chart_bar.dart';
import 'package:l17/widgets/tour_list_item.dart';
import 'package:provider/provider.dart';

class TourList extends StatefulWidget {
  double height;
  double width;

  TourList(this.height, this.width);

  @override
  _TourListState createState() => _TourListState();
}

class _TourListState extends State<TourList> {
  List<Tour> _items;
  int _overallDistance;
  @override
  Widget build(BuildContext context) {
    _items = Provider.of<Tours>(context).items;
    _overallDistance = Provider.of<Tours>(context).overallDistance();
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey.shade200,
          height: widget.height * 0.10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                alignment: Alignment.center,
                width: widget.width * 0.25,
                child: Text(
                  'Christophorus',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: widget.width * 0.05,
              ),
              ChartBar(_overallDistance, 3000, widget.height * 0.10),
              SizedBox(
                width: widget.width * 0.05,
              ),
              Container(
                width: widget.width * 0.25,
                alignment: Alignment.center,
                child: Text(
                  '$_overallDistance km',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: widget.height * 0.90,
          child: ListView.builder(
            itemBuilder: (context, position) {
              return TourListItem(position);
            },
            itemCount: _items.length,
          ),
        ),
      ],
    );
  }
}
