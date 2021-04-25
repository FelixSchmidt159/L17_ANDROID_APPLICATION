import 'package:flutter/material.dart';
import 'package:l17/widgets/create_pdf.dart';

import '../widgets/app_drawer.dart';
import '../widgets/tour_list.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int _selectedIndex = 0;

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
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.picture_as_pdf),
          label: 'PDF erzeugen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Fahrtenbuch',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_road),
          label: 'Fahrt hinzufügen',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.orange,
      backgroundColor: Colors.green,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
    );
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.bottom -
        kBottomNavigationBarHeight;
    final width = MediaQuery.of(context).size.width;

    List<Widget> _widgetOptions = <Widget>[
      CreatePdf(),
      TourList(height, width),
      TourList(height, width),
    ];

    return Scaffold(
      appBar: appBar,
      body: _widgetOptions.elementAt(_selectedIndex),
      drawer: AppDrawer(),
      bottomNavigationBar: bottomBar,
    );
  }
}
