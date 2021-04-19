import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tours.dart';
import '../providers/tour.dart';
import '../widgets/app_drawer.dart';

class ToursOverviewScreen extends StatefulWidget {
  @override
  _ToursOverviewScreenState createState() => _ToursOverviewScreenState();
}

class _ToursOverviewScreenState extends State<ToursOverviewScreen> {
  List<Tour> _items;

  @override
  void initState() {
    // _items = Provider.of<Tours>(context).items;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _items = Provider.of<Tours>(context).items;
    return Scaffold(
      appBar: AppBar(
        title: Text('Fahrtenbuch'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (context, position) {
          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
                        child: Text(
                          _items[position].licensePlate,
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
                        child: Text(
                          _items[position].roadCondition,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "5m",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.star_border,
                            size: 35.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 2.0,
                color: Colors.grey,
              )
            ],
          );
        },
        itemCount: _items.length,
      ),
      drawer: AppDrawer(),
    );
  }
}
