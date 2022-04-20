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
      int len = route["comments"]?.length ?? 0;

      return Container(
        width: 0.95 * devicewidth,
        height: 0.3 * deviceheight,
        child: ListView.separated(
          padding: const EdgeInsets.all(5),
          itemCount: len,
          itemBuilder: (context, index) {
            return Card(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                ListTile(
                  onTap: () {
                    ///스케줄카드를 눌렀을 떄 기능 구현
                  },
                  leading: Icon(
                    icons[index],
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    '${comments[index]}',
                    style: DayplanitLogoFont(
                        textStyle: const TextStyle(
                            color: Color.fromARGB(221, 72, 72, 72)),
                        fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    //시작,끝시간 초단위 삭제
                    '${startTime[index].toString().substring(0, 5)}~${endTime[index]..toString().substring(0, 5)}',
                  ),
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
      );
    });
  }
}
