import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/buttons.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/notification_text.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/schedule_class.dart';

class SetScheduleTab extends StatefulWidget {
  const SetScheduleTab({Key? key}) : super(key: key);

  @override
  State<SetScheduleTab> createState() => _SetScheduleTabState();
}

class _SetScheduleTabState extends State<SetScheduleTab> {
  bool _isNotiBoxShow1 = true;
  bool _isNotiBoxShow2 = true;

  _onNotiBox1ClosePressed() {
    setState(() {
      _isNotiBoxShow1 = false;
    });
  }

  _onNotiBox2ClosePressed() {
    setState(() {
      _isNotiBoxShow2 = false;
    });
  }

  Widget _buildNotiBox() {
    bool _isSetTimeNotiboxShow = _isNotiBoxShow2 &&
        context.watch<CreateScheduleStore>().scheduleList.isNotEmpty;
    return Column(
      children: [
        if (_isNotiBoxShow1 || _isSetTimeNotiboxShow)
          const SizedBox(height: 10),
        if (_isNotiBoxShow1)
          NotificationBox(
            title: "일정을 추가하고, 조정하고, 시간을 정해보세요.",
            onClosePressed: _onNotiBox1ClosePressed,
          ),
        if (_isNotiBoxShow1 && _isSetTimeNotiboxShow)
          const SizedBox(height: 10),
        if (_isSetTimeNotiboxShow)
          NotificationBox(
            title: "추가한 일정을 누르거나 일정 시작 전 회색 영역을 눌러 스케줄의 시작시간을 조절하세요.",
            onClosePressed: _onNotiBox2ClosePressed,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _buildNotiBox(),
            const Expanded(child: RecommendedSchedulesGrid()),
          ],
        ),
        if (context.watch<CreateScheduleStore>().isCustomBlockBeingMade)
          const Positioned.fill(child: CreateCustomBlock()),
        if (context.watch<CreateScheduleStore>().isScheduleBoxDragging)
          const Positioned.fill(
              child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: DeleteScheduleArea(),
          )),
        if (context.watch<CreateScheduleStore>().isDecidingScheduleStartsAt)
          const Positioned.fill(child: SizedBox())
      ],
    );
  }
}

class RecommendedSchedulesGrid extends StatelessWidget {
  const RecommendedSchedulesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late List<Schedule> places = <Schedule>[];
    late List<IconData> placeIcons = <IconData>[];
    for (var place in placeTypes) {
      places.add(Schedule(
          nameKor: place[1],
          placeType: place[0],
          color: place[2],
          // 아래는 임시로 부여하는 시간 데이터
          duration: Duration.zero));

      // 아이콘 저장
      placeIcons.add(place[3]);
    }

    // 박스 사이즈는 Expended로, 직접 결정해줄 필요 없음
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Expanded(
          child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 2 / 1),
              itemCount: placeTypes.length,
              itemBuilder: (BuildContext context, int index) {
                final Schedule place = places[index];
                final IconData placeIcon = placeIcons[index];

                return ElevatedButton.icon(
                  onPressed: () =>
                      context.read<CreateScheduleStore>().addSchedule(place),
                  style: ElevatedButton.styleFrom(
                      elevation: 2,
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: defaultBoxRadius)),
                  icon: FaIcon(
                    placeIcon,
                    color: place.color,
                    size: 15,
                  ),
                  label: Text(
                    place.nameKor,
                    style: mainFont(
                      color: place.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                );
              }),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    context.read<CreateScheduleStore>().addSchedule(Schedule(
                        nameKor: "",
                        placeType: "empty",
                        color: const Color.fromARGB(150, 72, 72, 72),
                        duration: Duration.zero));
                  },
                  style: ElevatedButton.styleFrom(
                      primary: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: defaultBoxRadius),
                      minimumSize: const Size(double.maxFinite, 40)),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    '빈 블록 추가',
                    style: mainFont(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  )),
              ElevatedButton.icon(
                  onPressed: () => context
                      .read<CreateScheduleStore>()
                      .onStartMakingCustomBlock(),
                  style: ElevatedButton.styleFrom(
                      primary: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: defaultBoxRadius),
                      minimumSize: const Size(double.maxFinite, 40)),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    '커스텀 블록 추가',
                    style: mainFont(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  )),
            ],
          ),
        )
      ]),
    );
  }
}

class DeleteScheduleArea extends StatefulWidget {
  const DeleteScheduleArea({Key? key}) : super(key: key);

  @override
  State<DeleteScheduleArea> createState() => _DeleteScheduleAreaState();
}

class _DeleteScheduleAreaState extends State<DeleteScheduleArea> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return isHovered
            ? Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: defaultBoxRadius, color: pointColor),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              )
            : Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: defaultBoxRadius,
                    color: const Color.fromARGB(212, 39, 39, 39)),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              );
      },
      onWillAccept: (data) {
        setState(() {
          isHovered = true;
        });
        return true;
      },
      onLeave: (data) {
        setState(() {
          isHovered = false;
        });
      },
      onAccept: (int scheduleIndex) {
        context.read<CreateScheduleStore>().removeSchedule(scheduleIndex);
        context.read<CreateScheduleStore>().onScheduleBoxDragEnd();
      },
    );
  }
}

class CreateCustomBlock extends StatefulWidget {
  const CreateCustomBlock({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateCustomBlock> createState() => _CreateCustomBlockState();
}

class _CreateCustomBlockState extends State<CreateCustomBlock> {
  final TextEditingController _controller = TextEditingController();
  bool _isInputExists = false;
  String _input = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _onAddCustomScheduleBtnPressed() {
      context.read<CreateScheduleStore>().addSchedule(Schedule(
          nameKor: _input,
          placeType: "custom",
          color: pointColor,
          duration: Duration.zero));
      context.read<CreateScheduleStore>().onEndMakingCustomBlock();
    }

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: defaultBoxRadius,
                  boxShadow: defaultBoxShadow),
              padding: const EdgeInsets.all(5),
              width: timeLineWidth + 20,
              height: itemHeight / 1.5,
              child: TextField(
                autofocus: true,
                controller: _controller,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: "일정 이름"),
                style: mainFont(
                    color: pointColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 15),
                onChanged: (input) {
                  if (input.isEmpty) {
                    setState(() {
                      _isInputExists = false;
                    });
                  } else {
                    setState(() {
                      _isInputExists = true;
                      _input = input;
                    });
                  }
                },
              ),
            ),
          ),
          Column(
            children: [
              SquareButton(
                  title: "추가하기",
                  activate: _isInputExists,
                  onPressed: _onAddCustomScheduleBtnPressed),
              SquareButton(
                title: "취소",
                onPressed:
                    context.read<CreateScheduleStore>().onEndMakingCustomBlock,
                isCancle: true,
              )
            ],
          ),
        ],
      ),
    );
  }
}
