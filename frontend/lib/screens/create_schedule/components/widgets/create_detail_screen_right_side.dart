import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';

class CreateDetailScreenRightSide extends StatelessWidget {
  const CreateDetailScreenRightSide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScheduleDetailTitle(),
        Expanded(
            child: Center(
          child: Text('여기에 상세일정 결정 관련 데이터 Display'),
        )),
        ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
                primary: primaryColor,
                minimumSize: const Size(double.maxFinite, 40),
                shape: RoundedRectangleBorder(borderRadius: buttonBoxRadius)),
            child: Text(
              "경로 생성하기",
              style: mainFont(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ))
      ],
    );
  }
}

class ScheduleDetailTitle extends StatelessWidget {
  const ScheduleDetailTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () => context.read<CreateScheduleStore>().backtoPrivDetail(),
            child: Container(
              alignment: Alignment.center,
              width: itemHeight / 2,
              height: itemHeight / 2,
              child: const FaIcon(FontAwesomeIcons.arrowLeft,
                  size: 15, color: Color.fromARGB(255, 117, 117, 117)),
              decoration: BoxDecoration(
                  color: context
                              .read<CreateScheduleStore>()
                              .indexOfCurrentlyDecidingDetail ==
                          0
                      ? const Color.fromARGB(255, 215, 215, 215)
                      : Colors.white,
                  borderRadius: defaultBoxRadius,
                  boxShadow: defaultBoxShadow),
            ),
          ),
          Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: context
                      .read<CreateScheduleStore>()
                      .roughSchedule[context
                          .watch<CreateScheduleStore>()
                          .indexOfCurrentlyDecidingDetail]
                      .color,
                  borderRadius: defaultBoxRadius,
                  boxShadow: defaultBoxShadow),
              padding: const EdgeInsets.all(5),
              width: detailTimeLineWidth,
              height: itemHeight / 1.5,
              child: Text(
                context
                    .read<CreateScheduleStore>()
                    .roughSchedule[context
                        .read<CreateScheduleStore>()
                        .indexOfCurrentlyDecidingDetail]
                    .nameKor,
                style: mainFont(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15),
              )),
          InkWell(
            onTap: () => context.read<CreateScheduleStore>().gotoNextDetail(),
            child: Container(
              alignment: Alignment.center,
              width: itemHeight / 2,
              height: itemHeight / 2,
              child: const FaIcon(FontAwesomeIcons.arrowRight,
                  size: 15, color: Color.fromARGB(255, 117, 117, 117)),
              decoration: BoxDecoration(
                  color: context
                              .read<CreateScheduleStore>()
                              .indexOfCurrentlyDecidingDetail ==
                          context
                                  .read<CreateScheduleStore>()
                                  .roughSchedule
                                  .length -
                              1
                      ? const Color.fromARGB(255, 215, 215, 215)
                      : Colors.white,
                  borderRadius: defaultBoxRadius,
                  boxShadow: defaultBoxShadow),
            ),
          )
          // IconButton(
          //     onPressed: () =>
          //         context.read<CreateScheduleStore>().gotoNextDetail(),
          //     icon: const FaIcon(FontAwesomeIcons.arrowRight, size: 15))
        ],
      ),
    );
  }
}
