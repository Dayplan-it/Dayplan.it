import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dayplan_it/constants.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final List<String> comments = <String>[
    '대중교통 1 시간 32 분 이동',
    '데이플래닛 미팅',
    '도보 10분 이동',
    '정식당 점심식사',
    '대중교통 20분 이동'
  ];

  final List<IconData> icons = <IconData>[
    Icons.directions_bus,
    Icons.location_on,
    Icons.directions_walk,
    Icons.restaurant,
    Icons.directions_bus
  ];

  final List<String> strat_time = <String>[
    "09:18",
    "11:00",
    "12:30",
    "12:40",
    "13:40",
  ];
  final List<String> end_time = <String>[
    "10:50",
    "12:30",
    "12:40",
    "13:40",
    "14:00",
  ];

  @override
  Widget build(BuildContext context) {
    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;
    return Container(
      width: 0.95 * devicewidth,
      height: 0.3 * deviceheight,
      child: ListView.separated(
        padding: EdgeInsets.all(5),
        itemCount: comments.length,
        itemBuilder: (context, index) {
          return Container(
              child: Card(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              ListTile(
                onTap: () {
                  print("ddd");
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
                  '${strat_time[index]}~${end_time[index]}',
                ),
              ),
            ]),
          ));
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
      decoration: BoxDecoration(
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
  }
}
