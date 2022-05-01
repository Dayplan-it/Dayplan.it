import 'package:dayplan_it/notification/notification.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:dayplan_it/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/start/landingpage.dart';
import 'package:dayplan_it/screens/start/signuppage.dart';
import 'package:dayplan_it/screens/start/loginpage.dart';
import 'package:dayplan_it/screens/mainpage.dart';

Future<void> main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (BuildContext context) => LoginProvider(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => HomeProvider(),
      )
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
