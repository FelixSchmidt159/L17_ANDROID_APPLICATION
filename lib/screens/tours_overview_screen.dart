import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../providers/tours.dart';
import '../providers/tour.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chart_bar.dart';
import '../widgets/tour_list_item.dart';

class ToursOverviewScreen extends StatefulWidget {
  @override
  _ToursOverviewScreenState createState() => _ToursOverviewScreenState();
}

class _ToursOverviewScreenState extends State<ToursOverviewScreen> {
  bool _showContent = false;
  List<Tour> _items;
  int _overallDistance;
  int _selectedIndex = 0;
  DateFormat dateFormat;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    'Christophorus',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: width * 0.05,
                ),
                ChartBar(_overallDistance, 3000, height * 0.10),
                SizedBox(
                  width: width * 0.05,
                ),
                Container(
                  width: width * 0.25,
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
            height: height * 0.90,
            child: ListView.builder(
              itemBuilder: (context, position) {
                return TourListItem(position);
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
