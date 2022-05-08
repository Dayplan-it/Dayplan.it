import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/home/home_screen.dart';
import 'package:dayplan_it/screens/profile/profile_screen.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/components/bottom_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  List<Widget> screenList = [const HomeScreen(), const ProfileScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DayplanitAppBar(
        isHomePage: true,
      ),
      body: screenList[_selectedIndex],
      bottomNavigationBar: DayplaitBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
