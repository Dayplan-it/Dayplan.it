import 'package:dayplan_it/screens/home/components/detailroutepopup.dart';
import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:provider/provider.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  Widget build(BuildContext context) {
    Detailpopup detailPopup = Detailpopup();
    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;
    return Consumer<HomeProvider>(builder: (context, provider, widget) {
      //여기서 프로
      Map<String, List<dynamic>> route =
          Provider.of<HomeProvider>(context, listen: false).scheduledetail;

      List<dynamic> comments = route["comments"] ?? [];
      List<dynamic> icon = route["icons"] ?? [];
      List<IconData> icons = [];

      for (int i = 0; i < icon.length; i++) {
        if (icon[i] == "walk") {
          icons.add(Icons.directions_walk);
        } else if (icon[i] == "transit") {
          icons.add(Icons.directions_bus);
        } else {
          icons.add(Icons.location_on);
        }
      }

      List<dynamic> startTime = route["start_time"] ?? [];
      List<dynamic> endTime = route["end_time"] ?? [];
      List<dynamic> detailRoute = route['detail'] ?? [];
      int len = route["comments"]?.length ?? 0;
      return ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Provider.of<HomeProvider>(context, listen: false)
                  .showNoSchedule
              ? Center(
                  child: Container(
                  width: 0.95 * devicewidth,
                  height: 0.3 * deviceheight,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.live_help,
                        color: subTextColor,
                      ),
                      Text("해당 날짜엔 아직 일정이 없습니다!",
                          style: mainFont(
                              textStyle: const TextStyle(color: subTextColor),
                              fontSize: 12)),
                    ],
                  )),
                ))
              : Container(
                  width: 0.95 * devicewidth,
                  height: 0.3 * deviceheight,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(5),
                    itemCount: len,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                onTap: () {
                                  int routeIndex;
                                  int startIndex;
                                  int endIndex;

                                  //마지막 장소일 떄는 전장소의 경로      장소 경로 장소 경로 장소
                                  if (index == len - 1) {
                                    routeIndex = index - 1;
                                    startIndex = index - 2;
                                    endIndex = index;
                                  }
                                  //홀수일떄는 경로
                                  else if (index % 2 != 0) {
                                    routeIndex = index;
                                    startIndex = index - 1;
                                    endIndex = index + 1;
                                  }
                                  //짝수일떄는 장소
                                  else {
                                    routeIndex = index + 1;
                                    startIndex = index;
                                    endIndex = index + 2;
                                  }
                                  detailPopup.setRouteDetail(
                                      context,
                                      detailRoute[startIndex],
                                      detailRoute[routeIndex],
                                      detailRoute[endIndex],
                                      devicewidth,
                                      deviceheight);
                                },
                                leading: Icon(
                                  icons[index],
                                  color:
                                      const Color.fromARGB(255, 122, 122, 122),
                                ),
                                title: Text(
                                  '${comments[index]}',
                                  style: DayplanitLogoFont(
                                      textStyle: const TextStyle(
                                          color:
                                              Color.fromARGB(221, 72, 72, 72)),
                                      fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(
                                    '${startTime[index].toString().substring(0, 5)}~${endTime[index]..toString().substring(0, 5)}'),
                              ),
                            ]),
                      );
                    },

                    ///구분선추가
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.all(
                      Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(71, 158, 158, 158),
                        offset: Offset(4.0, 4.0),
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4.0, -4.0),
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                ));
    });
  }
}
