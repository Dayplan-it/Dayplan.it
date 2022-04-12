import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';

class DayplanitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DayplanitAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 2,
      backgroundColor: Colors.white,
      leading: const Padding(
        // leading 이미지 사이즈 조절은 직접 안되므로 Padding 위젯 이용
        padding: EdgeInsets.fromLTRB(8, 2, 0, 2),
        child: Image(
          image: AssetImage('assets/icons/dayplanit_icon_blue.png'),
        ),
      ),
      title: Text(
        'Dayplan.it',
        style: DayplanitLogoFont(
            textStyle: const TextStyle(color: primaryColor),
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(CupertinoIcons.bell_fill),
          color: primaryColor,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings),
          color: primaryColor,
        ),
      ],
    );
  }
}
