import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/home/home_screen.dart';
import 'package:dayplan_it/screens/profile/profile_screen.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';

import 'components/bottom_nav_bar.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<CreateScheduleStore>(
            create: (context) => CreateScheduleStore())
      ],
      child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dayplan.it',
          home: MyApp())));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> screenList = [const HomeScreen(), const ProfileScreen()];

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
