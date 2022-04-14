import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dayplan_it/constants.dart';

class RecommendedSchedulesGrid extends StatelessWidget {
  const RecommendedSchedulesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late List<Place> places = <Place>[];
    for (var place in placeTypes) {
      places.add(Place(
          nameKor: place[1],
          nameEng: place[0],
          color: place[2],
          iconData: place[3]));
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color.fromARGB(29, 0, 0, 0), blurRadius: 30)
          ]),
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
              final Place place = places[index];

              return ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    elevation: 2,
                    primary: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                icon: FaIcon(
                  place.iconData,
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  primary: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
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

class Place {
  Place(
      {required this.nameKor,
      required this.nameEng,
      required this.color,
      required this.iconData});

  final String nameKor;
  final String nameEng;
  final Color color;
  final IconData iconData;
}
