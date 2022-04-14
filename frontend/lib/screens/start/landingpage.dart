import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Color(0xFF01578D), Color(0xFF80AFCC)],
        stops: [0, 1],
        begin: AlignmentDirectional(1, -1),
        end: AlignmentDirectional(-1, 1),
      )),
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/landingpage_icon.png',
              width: 500,
              height: 200,
              fit: BoxFit.fitHeight,
            )
          ]),
    );
  }
}
