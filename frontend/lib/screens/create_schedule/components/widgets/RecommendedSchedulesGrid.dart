import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place_rough.dart';

class RecommendedSchedulesGrid extends StatelessWidget {
  const RecommendedSchedulesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late List<PlaceRough> places = <PlaceRough>[];
    late List<IconData> placeIcons = <IconData>[];
    for (var place in placeTypes) {
      places.add(PlaceRough(
          nameKor: place[1],
          nameEng: place[0],
          color: place[2],

          // 아래는 임시로 부여하는 시간 데이터
          startsAt: DateTime.now(),
          endsAt: DateTime.now(),
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
              final PlaceRough place = places[index];
              final IconData placeIcon = placeIcons[index];

              return ElevatedButton.icon(
                onPressed: () =>
                    context.read<CreateScheduleStore>().addRoughSchedule(place),
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
