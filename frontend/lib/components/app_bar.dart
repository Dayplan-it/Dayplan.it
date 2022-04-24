import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';

class DayplanitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DayplanitAppBar({
    this.title = "Dayplan.it",
    this.subtitle = "",
    this.isHomePage = false,
  });
  final String title;
  final String subtitle;
  final bool isHomePage;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: Padding(
          // leading 이미지 사이즈 조절은 직접 안되므로 Padding 위젯 이용
          padding: const EdgeInsets.fromLTRB(8, 2, 0, 2),
          child: isHomePage
              ? const Image(
                  image: AssetImage('assets/icons/dayplanit_icon_blue.png'),
                )
              : IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context
                        .read<CreateScheduleStore>()
                        .onPopCreateScheduleScreen();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: primaryColor,
                  )),
        ),
        title: isHomePage
            ? Text(title,
                style: DayplanitLogoFont(
                    textStyle: const TextStyle(color: primaryColor),
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic))
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    Text(
                      subtitle,
                      style: mainFont(
                          textStyle: const TextStyle(color: subTextColor),
                          fontSize: subtitleSize),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Text(
                      title,
                      style: mainFont(
                        textStyle: const TextStyle(color: primaryColor),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ]),
        centerTitle: false,
        actions: isHomePage
            ? [
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
              ]
            : null);
  }
}
