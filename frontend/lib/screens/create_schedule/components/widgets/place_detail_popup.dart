import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/web_image.dart';
import 'package:dayplan_it/screens/create_schedule/components/api/fetch.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/buttons.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/google_map.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class PlaceDetail extends StatefulWidget {
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
  State<PlaceDetail> createState() => _PlaceDetailState();
}

class _PlaceDetailState extends State<PlaceDetail> {
  late Widget placeDetail;
  @override
  void initState() {
    placeDetail = FutureBuilder<Map>(
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
    super.initState();
  }

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
    return PointerInterceptor(
      child: Column(
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
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          itemCount:
                              data["reviews"].length + data["photo"].length,
                          itemBuilder: (context, index) {
                            if (index < data["reviews"].length) {
                              return _buildReviewBox(data["reviews"][index]);
                            } else {
                              return Padding(
                                  padding: EdgeInsets.only(
                                      top: (index - data["reviews"].length == 0
                                          ? 0
                                          : 5)),
                                  child: ClipRRect(
                                    borderRadius: defaultBoxRadius,
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: ImageNetwork(
                                        onPointer: true,
                                        image: data["photo"]
                                            [index - data["reviews"].length],
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
                                  ));
                            }
                          }),
                    ),
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ],
            ),
          ),
          SquareButton(
            title: widget.isForDecidingPlace ? "이 장소로 결정" : "이 장소 선택 취소하기",
            onPressed: () async {
              int _indexOfPlaceDecidingSchedule = context
                  .read<CreateScheduleStore>()
                  .indexOfPlaceDecidingSchedule;
              context.read<CreateScheduleStore>().onConvexHullControllOff();
              context.read<CreateScheduleStore>().setSelectedPlace(
                  widget.markerId.value, widget.title, widget.placeLatLng);
              if (widget.isForDecidingPlace) {
                context.read<CreateScheduleStore>().setPlaceForSchedule();
                context.read<CreateScheduleStore>().setMarkers(newMarkers: {
                  widget.markerId: await markerForPlace(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return placeDetail;
  }
}
