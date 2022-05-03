import 'package:dayplan_it/screens/mainpage.dart';
import 'package:dayplan_it/screens/start/landingpage.dart';
import 'package:dayplan_it/screens/start/loginpage.dart';
import 'package:dayplan_it/screens/start/signuppage.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:dayplan_it/screens/home/home_screen.dart';
import 'package:dayplan_it/screens/profile/profile_screen.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';

Future<void> main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<HomeProvider>(
        create: (BuildContext context) => HomeProvider(),
      ),
      ChangeNotifierProvider<CreateScheduleStore>(
          create: (context) => CreateScheduleStore())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Widget> screenList = [const HomeScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dayplan.it',
      routes: <String, WidgetBuilder>{
        '/main': (BuildContext context) => const MainPage(),
        '/login': (BuildContext context) => LoginPage(),
        '/signup': (BuildContext context) => SignupPage(),
        '/home': (BuildContext context) => HomeScreen(),
      },
      home: LandingPage(),
    );
  }
}
