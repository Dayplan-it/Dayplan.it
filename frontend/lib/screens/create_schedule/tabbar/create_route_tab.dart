import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/buttons.dart';
import 'package:dayplan_it/screens/create_schedule/components/class/route_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/class/schedule_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class CreateRouteTab extends StatefulWidget {
  const CreateRouteTab({Key? key}) : super(key: key);

  @override
  State<CreateRouteTab> createState() => _CreateRouteTabState();
}

class _CreateRouteTabState extends State<CreateRouteTab> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MapForRouteFind(),
      if (context.watch<CreateScheduleStore>().scheduleList.isEmpty)
        Positioned.fill(
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                    borderRadius: defaultBoxRadius,
                    color: const Color.fromARGB(212, 39, 39, 39)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "경로를 생성할",
                      style: mainFont(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "일정이 없습니다",
                      style: mainFont(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )))
      else if (!context.watch<CreateScheduleStore>().isRouteCreateAble())
        Positioned.fill(
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                    borderRadius: defaultBoxRadius,
                    color: const Color.fromARGB(212, 39, 39, 39)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "장소가 선택되지 않은",
                      style: mainFont(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "일정이 있습니다",
                      style: mainFont(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )))
    ]);
  }
}

class MapForRouteFind extends StatefulWidget {
  const MapForRouteFind({
    Key? key,
  }) : super(key: key);

  @override
  State<MapForRouteFind> createState() => _MapForRouteFindState();
}

class _MapForRouteFindState extends State<MapForRouteFind> {
  Future _createSchedule() async {
    if (context.read<CreateScheduleStore>().isRouteCreateAble()) {
      context.read<CreateScheduleStore>().setSchduleCreated(
          await ScheduleCreated.create(
              scheduleList: context.read<CreateScheduleStore>().scheduleList,
              scheduleDate: context.read<CreateScheduleStore>().scheduleDate));
      // print(context.read<CreateScheduleStore>().scheduleCreated.toJson());
      // print(context.read<CreateScheduleStore>().scheduleCreated.list);
      setState(() {
        isChanged = true;
      });
    }
  }

  bool isChanged = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SquareButtonWithLoading(
          title: "경로 생성하기",
          futureFunction: _createSchedule,
          activate: context.watch<CreateScheduleStore>().isRouteCreateAble()),
    );
  }
}
