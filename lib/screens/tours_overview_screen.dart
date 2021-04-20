import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tours.dart';
import '../providers/tour.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chart_bar.dart';

class ToursOverviewScreen extends StatefulWidget {
  @override
  _ToursOverviewScreenState createState() => _ToursOverviewScreenState();
}

class _ToursOverviewScreenState extends State<ToursOverviewScreen> {
  List<Tour> _items;
  int _overallDistance;
  int _selectedIndex = 0;
  @override
  void initState() {
    // _items = Provider.of<Tours>(context).items;
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _overallDistance = Provider.of<Tours>(context).overallDistance();
    _items = Provider.of<Tours>(context).items;
    final appBar = AppBar(
      title: const Text('Fahrtenbuch'),
      centerTitle: true,
    );
    final bottomBar = BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          backgroundColor: Colors.red,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Business',
          backgroundColor: Colors.green,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'School',
          backgroundColor: Colors.purple,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
          backgroundColor: Colors.pink,
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.bottom -
        kBottomNavigationBarHeight;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.grey.shade200,
            height: height * 0.10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: width * 0.25,
                  child: Text('Christophorus'),
                ),
                SizedBox(
                  width: width * 0.05,
                ),
                ChartBar('test', _overallDistance, 3000, height * 0.10),
                SizedBox(
                  width: width * 0.05,
                ),
                Container(
                  width: width * 0.25,
                  alignment: Alignment.center,
                  child: Text('$_overallDistance km'),
                ),
              ],
            ),
          ),
          Container(
            height: height * 0.90,
            child: ListView.builder(
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
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 12.0, 12.0, 6.0),
                              child: Text(
                                _items[position].licensePlate,
                                style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 6.0, 12.0, 12.0),
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
          ),
        ],
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: bottomBar,
    );
  }
}
