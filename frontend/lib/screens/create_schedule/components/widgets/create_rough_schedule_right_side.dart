import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place.dart';

class RecommendedSchedulesGrid extends StatelessWidget {
  const RecommendedSchedulesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late List<PlaceDurationOnly> places = <PlaceDurationOnly>[];
    late List<IconData> placeIcons = <IconData>[];
    for (var place in placeTypes) {
      places.add(PlaceDurationOnly(
          nameKor: place[1],
          placeType: place[0],
          color: place[2],

          // 아래는 임시로 부여하는 시간 데이터
          duration: const Duration(seconds: 1)));

      // 아이콘 저장
      placeIcons.add(place[3]);
    }

    // 박스 사이즈는 Expended로, 직접 결정해줄 필요 없음
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: defaultBoxRadius,
          boxShadow: defaultBoxShadow),
      clipBehavior: Clip.hardEdge,
      child: Stack(children: [
        GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                childAspectRatio: 2 / 1),
            itemCount: placeTypes.length,
            itemBuilder: (BuildContext context, int index) {
              final PlaceDurationOnly place = places[index];
              final IconData placeIcon = placeIcons[index];

              return ElevatedButton.icon(
                onPressed: () => context
                    .read<CreateScheduleStore>()
                    .addScheduleDurationOnly(place),
                style: ElevatedButton.styleFrom(
                    elevation: 2,
                    primary: Colors.white,
                    shape:
                        RoundedRectangleBorder(borderRadius: defaultBoxRadius)),
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
        Positioned(
          bottom: 2,
          right: 2,
          child: ElevatedButton.icon(
              onPressed: () => context
                  .read<CreateScheduleStore>()
                  .onStartMakingCustomBlock(),
              style: ElevatedButton.styleFrom(
                  primary: primaryColor,
                  shape:
                      RoundedRectangleBorder(borderRadius: defaultBoxRadius)),
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
        )
      ]),
    );
  }
}

class NoScheduleText extends StatelessWidget {
  const NoScheduleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              "일정이 없습니다",
              style: mainFont(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "일정 블록을 선택하거나",
              style: mainFont(color: subTextColor),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "커스텀 블록을 만들어주세요",
              style: mainFont(color: subTextColor),
            )
          ],
        )
      ],
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
    return Column(
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
            width: roughTimeLineWidth + 20,
            height: itemHeight / 1.5,
            child: TextField(
              autofocus: true,
              controller: _controller,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: "일정 이름"),
              style: mainFont(
                  color: pointColor, fontWeight: FontWeight.w900, fontSize: 15),
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
            ElevatedButton(
                onPressed: _isInputExists
                    ? () {
                        context
                            .read<CreateScheduleStore>()
                            .addScheduleDurationOnly(PlaceDurationOnly(
                                nameKor: _input,
                                placeType: "custom",
                                color: pointColor,
                                duration: const Duration(seconds: 1)));
                        context
                            .read<CreateScheduleStore>()
                            .onEndMakingCustomBlock();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    minimumSize: const Size(double.maxFinite, 40),
                    shape:
                        RoundedRectangleBorder(borderRadius: buttonBoxRadius)),
                child: Text(
                  "추가하기",
                  style: mainFont(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )),
            ElevatedButton(
                onPressed: () => context
                    .read<CreateScheduleStore>()
                    .onEndMakingCustomBlock(),
                style: ElevatedButton.styleFrom(
                    primary: pointColor,
                    minimumSize: const Size(double.maxFinite, 40),
                    shape:
                        RoundedRectangleBorder(borderRadius: buttonBoxRadius)),
                child: Text(
                  "취소",
                  style: mainFont(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )),
          ],
        ),
      ],
    );
  }
}
