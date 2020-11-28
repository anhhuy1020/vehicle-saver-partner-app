import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/app_router.dart';
import 'package:vehicles_saver_partner/blocs/demand_bloc.dart';
import 'package:vehicles_saver_partner/network/socket/socket_connector.dart';
import 'package:vehicles_saver_partner/screens/home/pages/profile_page.dart';
import 'package:vehicles_saver_partner/screens/home/pages/history_page.dart';
import 'package:vehicles_saver_partner/screens/home/pages/home_page.dart';
import 'package:vehicles_saver_partner/screens/home/pages/notifications_page.dart';
import 'package:vehicles_saver_partner/theme/style.dart';

class HomeScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  int _selectedIndex = 0;
  DemandBloc demandBloc;
  List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    HistoryPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _onIconTapped(int index) {
    print('_onIconTapped :$index');
    if (index == 2) {
      demandBloc.isHavingDemand()?
      Navigator.of(context).pushNamed(AppRoute.trackingDemandScreen):
      Navigator.of(context).pushNamed(AppRoute.listDemandScreen);
    } else {
      setState(() {
        _selectedIndex = index < 2 ? index : index - 1;
      });
    }
    print("_selectedIndex: $_selectedIndex");
  }

  @override
  Widget build(BuildContext context) {
    demandBloc = Provider.of<DemandBloc>(context);
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text("Trang chủ", style: TextStyle(color: Colors.black)),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex < 2? _selectedIndex: _selectedIndex + 1,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          iconSize: 30,
          selectedItemColor: Colors.amber[600],
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Trang chủ'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Lịch sử'),
            BottomNavigationBarItem(
                icon: Icon(Icons.view_list),
                label: 'Danh sách yêu cầu'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Thông báo'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Tài khoản'),
          ],
          onTap: _onIconTapped,

        ),

      );
    }
}
