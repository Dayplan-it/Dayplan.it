import 'package:dayplan_it/screens/create_schedule/tabbar/select_place_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/notification_text.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/timeLine_vertical.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/tabbar/set_schedule_tab.dart';

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
  void initState() {
    // context.read<CreateScheduleStore>().animationController =
    //     AnimationController(duration: Duration(seconds: 5), vsync: this);
    // context.read<CreateScheduleStore>().animation = IntTween(begin: 47, end: 30)
    //     .animate(context.read<CreateScheduleStore>().animationController);
    //_animation.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
        child: Row(children: [
          Expanded(
              flex: context.watch<CreateScheduleStore>().timelineWidthFlex,
              //context.watch<CreateScheduleStore>().animation.value,
              child: const TimeLine()),
          const SizedBox(
            width: 8,
          ),
          const Expanded(flex: 53, child: CreateScheduleScreenRightSide())
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

  Widget _buildTabTitle(String title) {
    return Center(
        child: Text(
      title,
      style: mainFont(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
    ));
  }

  void _onTabChange() {
    setState(() {
      index = context.read<CreateScheduleStore>().tabController.index;
    });
    context.read<CreateScheduleStore>().setTimeLineWidthFlexByTabIndex(index);
    //context.read<CreateScheduleStore>().animateTimeLine();
  }

  @override
  void initState() {
    context.read<CreateScheduleStore>().tabController = TabController(
      length: 3,
      vsync: this,
    );

    context.read<CreateScheduleStore>().tabController.addListener(() {
      _onTabChange();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 25,
          width: double.infinity,
          child: TabBarView(
            controller: context.read<CreateScheduleStore>().tabController,
            children: [
              _buildTabTitle("일정 추가 및 조정"),
              _buildTabTitle("장소 설정"),
              _buildTabTitle("경로 생성"),
            ],
          ),
        ),
        TabBar(
          controller: context.read<CreateScheduleStore>().tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          tabs: const [
            Tab(
              iconMargin: EdgeInsets.only(bottom: 2),
              icon: Icon(Icons.schedule_rounded),
            ),
            Tab(
              iconMargin: EdgeInsets.only(bottom: 2),
              icon: Icon(
                CupertinoIcons.placemark_fill,
              ),
            ),
            Tab(
              iconMargin: EdgeInsets.only(bottom: 2),
              icon: Icon(Icons.route_rounded),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: context.read<CreateScheduleStore>().tabController,
            children: [
              const SetScheduleTab(),
              const SelectPlaceTab(),
              Text(index.toString()),
            ],
          ),
        ),
        Column(
          children: [
            if (context.watch<CreateScheduleStore>().scheduleList.isEmpty)
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
    );
  }
}
