import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:flutter/material.dart';

import 'package:dayplan_it/screens/home/home_screen.dart';
import 'package:dayplan_it/screens/profile/profile_screen.dart';
import 'package:dayplan_it/components/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  List<Widget> screenList = [const HomeScreen(), const ProfileScreen()];

  void _onItemTapped(int index) {
    context.read<HomeProvider>().setNoSchedule(true);
    context.read<HomeProvider>().deleteData();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenList[_selectedIndex],
      bottomNavigationBar: DayplaitBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
