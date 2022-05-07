import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/create_schedule/tabbar/create_route_tab.dart';
import 'package:dayplan_it/screens/create_schedule/tabbar/select_place_tab.dart';
import 'package:dayplan_it/screens/create_schedule/tabbar/set_schedule_tab.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/notification_text.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/timeLine_vertical.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';

class CreateScheduleScreen extends StatefulWidget {
  const CreateScheduleScreen({Key? key, required this.date}) : super(key: key);
  final DateTime date;

  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  @override
  void initState() {
    context.read<CreateScheduleStore>().scheduleDate = widget.date;
    context.read<CreateScheduleStore>().scheduleListStartsAt =
        widget.date.add(const Duration(hours: 9));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<CreateScheduleStore>().onPopCreateScheduleScreen();
        return true;
      },
      child: Scaffold(
          appBar: DayplanitAppBar(
            title: "일정 생성하기",
            subtitle:
                "${widget.date.month.toString()}월 ${widget.date.day.toString()}일",
            isHomePage: false,
          ),
          body: const CreateScheduleScreenBody()),
    );
  }
}

class CreateScheduleScreenBody extends StatefulWidget {
  const CreateScheduleScreenBody({Key? key}) : super(key: key);

  @override
  State<CreateScheduleScreenBody> createState() =>
      _CreateScheduleScreenBodyState();
}

class _CreateScheduleScreenBodyState extends State<CreateScheduleScreenBody>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
        child: Row(children: [
          AnimatedSize(
              alignment: Alignment.centerLeft,
              curve: Curves.fastOutSlowIn,
              duration: tabResizeAnimationDuration,
              child: SizedBox(
                  width: (screenWidth - 24) *
                      context
                          .watch<CreateScheduleStore>()
                          .timelineWidthFlex
                          .toDouble() /
                      100,
                  child: const TimeLine())),
          const SizedBox(
            width: 8,
          ),
          AnimatedSize(
              alignment: Alignment.centerLeft,
              curve: Curves.fastOutSlowIn,
              duration: tabResizeAnimationDuration,
              child: SizedBox(
                  width: (screenWidth - 24) *
                      (1 -
                          (context
                                  .watch<CreateScheduleStore>()
                                  .timelineWidthFlex
                                  .toDouble() /
                              100)),
                  child: const CreateScheduleScreenRightSide()))
        ]));
  }
}

class CreateScheduleScreenRightSide extends StatefulWidget {
  const CreateScheduleScreenRightSide({Key? key}) : super(key: key);

  @override
  State<CreateScheduleScreenRightSide> createState() =>
      _CreateScheduleScreenRightSideState();
}

class _CreateScheduleScreenRightSideState
    extends State<CreateScheduleScreenRightSide> with TickerProviderStateMixin {
  int index = 0;

  Widget _buildTabTitle(IconData icon, String title, int tabIndex) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (index != tabIndex) ...[
          Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ] else ...[
          SizedBox(
            width: 45,
            child: Text(
              title,
              style: mainFont(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ]
      ],
    ));
  }

  void _onTabChange() {
    setState(() {
      index = context.read<CreateScheduleStore>().tabController.index;
    });
    context.read<CreateScheduleStore>().setTimeLineWidthFlexByTabIndex(index);
    // if (context.read<CreateScheduleStore>().googleMapController !=
    //     null) {
    //   if (index == 1) {
    //     context
    //         .read<CreateScheduleStore>()
    //         .customInfoWindowController!
    //         .showAllInfoWindow!();
    //   }
    // }
    if (index == 2) {
      context.read<CreateScheduleStore>().onCreateRouteTabStart();
    } else {
      context.read<CreateScheduleStore>().onCreateRouteTabEnd();
    }
    //context.read<CreateScheduleStore>().animateTimeLine();
  }

  @override
  void initState() {
    context.read<CreateScheduleStore>().tabController = TabController(
        length: 3, vsync: this, animationDuration: tabResizeAnimationDuration);

    context.read<CreateScheduleStore>().tabController.addListener(() {
      _onTabChange();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, // Positioned 사용하기 위해 Stack 사용함
        // 스케줄 Reorder시에 0시에 생기는 DragTarget때문에 이같은 과정이 필요
        children: [
          Positioned(
              top: -reorderDragTargetHeight / 2,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  TabBar(
                    controller:
                        context.read<CreateScheduleStore>().tabController,
                    indicatorColor: primaryColor,
                    labelColor: primaryColor,
                    labelPadding: EdgeInsets.zero,
                    tabs: [
                      Tab(
                        child: _buildTabTitle(
                            Icons.schedule_rounded, "일정 추가 및 조정", 0),
                      ),
                      Tab(
                        child: _buildTabTitle(
                            CupertinoIcons.placemark_fill, "장소 설정", 1),
                      ),
                      Tab(
                        child: _buildTabTitle(Icons.route_rounded, "경로 생성", 2),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller:
                          context.read<CreateScheduleStore>().tabController,
                      children: const [
                        SetScheduleTab(),
                        SelectPlaceTab(),
                        CreateRouteTab(),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (context
                          .watch<CreateScheduleStore>()
                          .scheduleList
                          .isEmpty)
                        const NotificationText(
                          title: "일정이 없습니다",
                          isRed: true,
                        ),
                      // SquareButton(
                      //   title: "일정 결정하기",
                      //   activate:
                      //       context.read<CreateScheduleStore>().scheduleList.isNotEmpty,
                      //   onPressed: () {},
                      // ),
                    ],
                  ),
                ],
              ))
        ]);
  }
}
