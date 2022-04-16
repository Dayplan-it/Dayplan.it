import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';

class NoScheduleText extends StatelessWidget {
  const NoScheduleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              "일정이 없습니다",
              style: mainFont(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "일정 블록을 선택하거나",
              style: mainFont(color: subTextColor),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "커스텀 블록을 만들어주세요",
              style: mainFont(color: subTextColor),
            )
          ],
        )
      ],
    );
  }
}
