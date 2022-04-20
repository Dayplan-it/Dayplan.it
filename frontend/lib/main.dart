import 'package:dayplan_it/components/floating_btn.dart';
import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/home/home_screen.dart';
import 'package:dayplan_it/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'components/app_bar.dart';
import 'components/bottom_nav_bar.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => HomeProvider(),
        )
      ],
      child: MaterialApp(
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
  List<Widget> screenList = [HomeScreen(), ProfileScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DayplanitAppBar(),
      body: screenList[_selectedIndex],
      bottomNavigationBar: DayplaitBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
