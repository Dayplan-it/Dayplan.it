import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_network/image_network.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/api/fetch.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/buttons.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/google_map.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class PlaceDetail extends StatelessWidget {
  const PlaceDetail(this.context, this.markerId, this.placeLatLng, this.title,
      this.rating, this.length,
      {Key? key, required this.isForDecidingPlace})
      : super(key: key);

  final BuildContext context;
  final MarkerId markerId;
  final LatLng placeLatLng;
  final String title;
  final String? rating;
  final int? length;

  final bool isForDecidingPlace;

  @override
  Widget build(BuildContext context) {
    Widget _buildReviewBox(Map review) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RatingBarIndicator(
                      itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                      itemCount: 5,
                      itemSize: 15,
                      direction: Axis.horizontal,
                      rating: review["rating"].toDouble()),
                  const SizedBox(
                    width: 5,
                  ),
                  UnconstrainedBox(
                    child: Text(
                      review["relative_time_description"],
                      style: mainFont(color: subTextColor, fontSize: 11.5),
                    ),
                  )
                ],
              ),
              Text(
                review["text"],
                style: mainFont(color: Colors.black, fontSize: 13),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      );
    }

    Widget _detailPage(Map data) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                      child: Text(
                        data["name"],
                        style:
                            mainFont(fontWeight: FontWeight.w800, fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star,
                            color: pointColor,
                            size: 20,
                          ),
                          Text(
                            data["rating"].toString(),
                            style: mainFont(
                                color: pointColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${data["user_ratings_total"].toString()}개의 리뷰",
                            style: mainFont(
                                color: subTextColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: data["reviews"].length,
                        itemBuilder: (context, index) =>
                            _buildReviewBox(data["reviews"][index]),
                      ),
                    ),
                    if (data["photo"].isNotEmpty)
                      const SizedBox(
                        height: 90,
                      )
                  ],
                ),
                if (data["photo"].isNotEmpty)
                  DraggableScrollableSheet(
                    initialChildSize: 0.13,
                    minChildSize: 0.13,
                    maxChildSize: data["photo"].length == 1 ? 0.45 : 0.7,
                    expand: true,
                    builder: (context, scrollController) {
                      return Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: defaultBoxShadow,
                              borderRadius: defaultBoxRadius),
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: ClipRRect(
                            borderRadius: defaultBoxRadius,
                            child: ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                controller: scrollController,
                                itemCount: data["photo"].length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return const Icon(
                                      Icons.drag_handle,
                                      color: subTextColor,
                                      size: 17,
                                    );
                                  }

                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: (index - 1 == 0 ? 0 : 5)),
                                    child: ClipRRect(
                                      borderRadius: defaultBoxRadius,
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: ImageNetwork(
                                          image: data["photo"][index - 1],
                                          height: 200,
                                          width: 250,
                                          fitWeb: BoxFitWeb.cover,
                                          onLoading:
                                              const CircularProgressIndicator(
                                            color: primaryColor,
                                          ),
                                          onError: const Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ));
                    },
                  )
              ],
            ),
          ),
          SquareButton(
            title: isForDecidingPlace ? "이 장소로 결정" : "이 장소 선택 취소하기",
            onPressed: () async {
              int _indexOfPlaceDecidingSchedule = context
                  .read<CreateScheduleStore>()
                  .indexOfPlaceDecidingSchedule;
              context.read<CreateScheduleStore>().onConvexHullControllOff();
              context
                  .read<CreateScheduleStore>()
                  .setSelectedPlace(markerId.value, title, placeLatLng);
              if (isForDecidingPlace) {
                context.read<CreateScheduleStore>().setPlaceForSchedule();
                context.read<CreateScheduleStore>().setMarkers(newMarkers: {
                  markerId: await markerForPlace(
                    place: context
                        .read<CreateScheduleStore>()
                        .scheduleList[_indexOfPlaceDecidingSchedule],
                    parentKey: context.read<CreateScheduleStore>().screenKey,
                  )
                });
              } else {
                context
                    .read<CreateScheduleStore>()
                    .removeSelectedPlaceFromSchedule();
                context.read<CreateScheduleStore>().clearMarkers();
              }

              Navigator.of(context).pop();
            },
            activate: true,
          )
        ],
      );
    }

    return FutureBuilder<Map>(
      future: fetchPlaceDetail(
          placeId: context.read<CreateScheduleStore>().selectedPlaceId,
          shouldGetImg: true),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _detailPage(snapshot.data!);
        }
        return const Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        );
      },
    );
  }
}
