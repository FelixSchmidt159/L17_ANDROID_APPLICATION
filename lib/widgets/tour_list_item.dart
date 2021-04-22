import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../providers/tours.dart';
import '../providers/tour.dart';

class TourListItem extends StatefulWidget {
  final int position;

  TourListItem(this.position);

  @override
  _TourListItemState createState() => _TourListItemState();
}

class _TourListItemState extends State<TourListItem> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    List<Tour> _items;
    _items = Provider.of<Tours>(context).items;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
                  child: Text(
                    _items[widget.position].tourBegin,
                    style: TextStyle(
                      fontSize: 18.0,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
                  child: Text(
                    _items[widget.position].tourEnd,
                    style: TextStyle(
                      fontSize: 18.0,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
                  child: Text(
                    DateFormat.MMMMd('de_DE')
                        .format(_items[widget.position].timestamp),
                    style: TextStyle(
                      fontSize: 14.0,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
                  child: Text(
                    _items[widget.position].distance.toString() + "km",
                    style: TextStyle(
                      fontSize: 14.0,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(_showContent
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down),
                      onPressed: () {
                        setState(() {
                          _showContent = !_showContent;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        _showContent
            ? Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Text('hiiii'),
              )
            : Container(),
        Divider(
          height: 2.0,
          color: Colors.grey,
        ),
      ],
    );
  }
}
