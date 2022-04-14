import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:resizable_widget/resizable_widget.dart';

const double ITEM_HEIGHT = 72;
const int HOURS = 24;

class ScheduleBoxRough extends StatelessWidget {
  const ScheduleBoxRough({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResizableWidget(
      isHorizontalSeparator: false,
      children: [
        Container(color: Colors.greenAccent),
        ResizableWidget(
          children: [
            Container(color: Colors.greenAccent),
            Container(color: Colors.yellowAccent),
            Container(color: Colors.redAccent),
          ],
          percentages: const [0.2, 0.5, 0.3],
        ),
        Container(color: Colors.redAccent),
      ],
    );
  }
}

class TimeLine extends StatefulWidget {
  const TimeLine({Key? key}) : super(key: key);

  @override
  State<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  late final ScrollController _scrollController = ScrollController(
      initialScrollOffset: ITEM_HEIGHT * 8 - 20, keepScrollOffset: false);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Row(
        children: [
          Expanded(
              flex: 20,
              child: Column(
                children: [
                  for (int i = 0; i < HOURS + 1; i++)
                    SizedBox(
                      height: i != 0 && i != 24 ? ITEM_HEIGHT : ITEM_HEIGHT / 2,
                      child: i != 0 && i != 24
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                (i.toString() + (i < 12 ? ' AM' : ' PM')),
                                style:
                                    mainFont(color: subTextColor, fontSize: 12),
                              ))
                          : null,
                    )
                ],
              )),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 70,
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  for (int i = 0; i < HOURS; i++)
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: ITEM_HEIGHT,
                          color: skyBlue,
                        ),
                        const Divider(
                          height: 0,
                          indent: 10,
                          endIndent: 10,
                          thickness: 1,
                          color: Colors.white,
                        )
                      ],
                    )
                ],
              ),
            ),
          ),
          const Expanded(
            flex: 5,
            child: SizedBox(),
          )
        ],
      ),
    );
  }
}
