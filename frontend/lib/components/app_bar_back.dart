import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';

class DayplanitAppBarWithBack extends StatelessWidget
    implements PreferredSizeWidget {
  const DayplanitAppBarWithBack({Key? key}) : super(key: key);

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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: primaryColor,
        ),
      ],
    );
  }
}
