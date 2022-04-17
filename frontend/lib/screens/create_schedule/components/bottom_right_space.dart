import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place_rough.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

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
            width: timeLineWidth + 20,
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
                        context.read<CreateScheduleStore>().addRoughSchedule(
                            PlaceRough(
                                nameKor: _input,
                                nameEng: "custom",
                                color: pointColor,
                                startsAt: DateTime(2023),
                                endsAt: DateTime(2023),
                                duration: const Duration(days: 1)));
                        context
                            .read<CreateScheduleStore>()
                            .onEndMakingCustomBlock();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    minimumSize: const Size(double.maxFinite, 40),
                    shape:
                        RoundedRectangleBorder(borderRadius: defaultBoxRadius)),
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
                        RoundedRectangleBorder(borderRadius: defaultBoxRadius)),
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
