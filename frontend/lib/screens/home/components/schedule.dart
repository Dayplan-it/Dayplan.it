import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/route_card.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, provider, widget) {
      if (Provider.of<HomeProvider>(context, listen: false)
          .isDateNewlySelected) {
        return const Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        );
      }
      return Provider.of<HomeProvider>(context, listen: false).showNoSchedule
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.live_help,
                  color: subTextColor,
                ),
                Text("해당 날짜엔 아직 일정이 없습니다!",
                    style: mainFont(color: subTextColor, fontSize: 12)),
              ],
            )
          : (Provider.of<HomeProvider>(context, listen: true)
                      .mainMapController !=
                  null
              ? ClipRRect(
                  borderRadius: defaultBoxRadius,
                  child: ScheduleOrderCardListView(
                    scheduleOrderList:
                        Provider.of<HomeProvider>(context, listen: false)
                            .schedule
                            .list,
                    routeMapController:
                        Provider.of<HomeProvider>(context, listen: false)
                            .mainMapController!,
                  ),
                )
              : SizedBox.shrink());
    });
  }
}
