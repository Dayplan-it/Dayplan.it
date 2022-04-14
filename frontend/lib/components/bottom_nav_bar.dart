import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';

class DayplaitBottomNavBar extends StatelessWidget {
  final selectedIndex;
  ValueChanged<int> onItemTapped;

  DayplaitBottomNavBar(
      {Key? key, this.selectedIndex, required this.onItemTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        elevation: 10,
        showUnselectedLabels: false,
        currentIndex: selectedIndex,
        items: [
          homeIcon(),
          profileIcon(),
        ],
        selectedItemColor: primaryColor,
        onTap: onItemTapped);
  }

  BottomNavigationBarItem profileIcon() {
    return const BottomNavigationBarItem(
      icon: Icon(
        Icons.person_outline_rounded,
        color: subTextColor,
      ),
      activeIcon: Icon(
        Icons.person_rounded,
        color: primaryColor,
      ),
      label: 'Profile',
    );
  }

  BottomNavigationBarItem homeIcon() {
    return const BottomNavigationBarItem(
      icon: Icon(
        Icons.home_outlined,
        color: subTextColor,
      ),
      activeIcon: Icon(
        Icons.home,
        color: primaryColor,
      ),
      label: 'Home',
    );
  }
}
