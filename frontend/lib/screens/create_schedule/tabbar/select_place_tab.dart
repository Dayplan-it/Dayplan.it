import 'dart:convert';
import 'package:dayplan_it/screens/create_schedule/components/widgets/place_detail_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/buttons.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/google_map.dart';

class SelectPlaceTab extends StatefulWidget {
  const SelectPlaceTab({Key? key}) : super(key: key);

  @override
  State<SelectPlaceTab> createState() => _SelectPlaceTabState();
}

class _SelectPlaceTabState extends State<SelectPlaceTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        const MapWithSearchBox(),
        if (context.watch<CreateScheduleStore>().scheduleList.isEmpty)
          Positioned.fill(
              child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      borderRadius: defaultBoxRadius,
                      color: const Color.fromARGB(212, 39, 39, 39)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "장소를 선택할",
                        style: mainFont(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "일정이 없습니다",
                        style: mainFont(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ))),
        // Positioned.fill(
        //     child: Column(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: const [
        //       NotificationBox(
        //         title: "일정별 장소를 결정합니다",
        //       ),
        //       NotificationBox(
        //         title: "장소가 선택된 일정이 있다면 해당 장소 주위로 장소를 추천합니다",
        //       ),
        //     ])),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MapWithSearchBox extends StatefulWidget {
  const MapWithSearchBox({Key? key}) : super(key: key);

  @override
  State<MapWithSearchBox> createState() => _MapWithSearchBoxState();
}

class _MapWithSearchBoxState extends State<MapWithSearchBox> {
  @override
  void initState() {
    super.initState();
    _getUserLoc();
  }

  /// 기기로부터 위치정보 사용 권한을 받고 위치정보를 가져오거나
  /// AlertDialog를 띄우는 함수
  _getUserLoc() async {
    Position tempUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userPosition = tempUserPosition;
    });
    // if (await Permission.location.request().isGranted) {
    //   _userPosition = await Geolocator.getCurrentPosition(
    //       desiredAccuracy: LocationAccuracy.high);
    // } else {
    //   // 위치정보 사용 거절당했을 경우 필요하다는 다이얼로그 띄우기
    //   await showDialog(
    //       context: context,
    //       builder: (BuildContext context) => CupertinoAlertDialog(
    //             title: const Text('위치정보 요청'),
    //             content: const Text('데이플래닛을 사용하기 위해서는 위치정보가 필요합니다.'),
    //             actions: <Widget>[
    //               CupertinoDialogAction(
    //                 child: const Text('거절'),
    //                 onPressed: () {
    //                   context
    //                       .read<CreateScheduleStore>()
    //                       .tabController
    //                       .animateTo(0);
    //                 },
    //               ),
    //               CupertinoDialogAction(
    //                 child: const Text('설정'),
    //                 onPressed: () => openAppSettings(),
    //               ),
    //             ],
    //           ));
    //   if (await Permission.location.request().isGranted) {
    //     _userPosition = await Geolocator.getCurrentPosition(
    //         desiredAccuracy: LocationAccuracy.high);
    //   } else {
    //     throw Error();
    //   }
    // }
  }

  /// 구글의 Autocomplete API를 사용해 자동완성 검색어를 가져오는 함수
  Future<dynamic> _fetchAutoComplete(String input) async {
    try {
      final response = await Dio().get(
          '$commonUrl/api/placeautocomplete?input=$input&lat=${_userPosition.latitude}&lng=${_userPosition.longitude}&is_rankby_distance=true');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('서버에 문제가 발생했습니다');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Map> _fetchPlaceDetail(
      {required String placeId, bool shouldGetImg = false}) async {
    try {
      final response = await Dio().get(
          '$commonUrl/api/placedetail?place_id=$placeId&should_get_img=$shouldGetImg');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('서버에 문제가 발생했습니다');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List> _fetchPlaceRecommend(String placeType) async {
    LatLng position = context.read<CreateScheduleStore>().placeRecommendPoint;
    try {
      final response = await Dio().get(
          '$commonUrl/api/placerecommend?lat=${position.latitude}&lng=${position.longitude}&place_type=$placeType');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('서버에 문제가 발생했습니다');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Widget> _buildGoogleMap() async {
    await _getUserLoc();
    return MapWithCustomInfoWindow(
      onMapCreated: _onMapCreated,
      initPosition: _userPosition,
      markers: markers,
    );
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void _setMarker(Map<MarkerId, Marker> newMarkers) {
    setState(() {
      markers = newMarkers;
    });
  }

  void _addMarker(LatLng placeLatLng, String title, String? rating, int? minute,
      {required String markerIdStr}) async {
    final MarkerId markerId = MarkerId(markerIdStr);

    final Marker marker = await _createMarker(
      placeLatLng,
      title,
      rating,
      minute,
      markerIdStr,
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  Future<Marker> _createMarker(LatLng placeLatLng, String title, String? rating,
      int? length, String placeId) async {
    final MarkerId markerId = MarkerId(placeId);
    _onTap() async {
      context
          .read<CreateScheduleStore>()
          .setSelectedPlace(placeId, title, placeLatLng);

      //context.read<CreateScheduleStore>().toggleIsLookingPlaceDetail();

      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: defaultBoxRadius),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.7,
                child: PlaceDetail(
                  fetchPlaceDetail: _fetchPlaceDetail,
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: PlaceDetailConfirmButton(
                    marker: markers[markerId]!,
                    markerId: markerId,
                    setMarker: _setMarker,
                  ),
                )
              ],
              actionsAlignment: MainAxisAlignment.center,
            );
          });
    }

    return await markerWithCustomInfoWindow(
        context,
        context.read<CreateScheduleStore>().googleMapController!,
        markerId,
        placeLatLng,
        title,
        rating,
        length,
        _onTap);
  }

  void _clearMarker() async {
    _setMarker(<MarkerId, Marker>{});
  }

  void _onMapCreated(GoogleMapController controller) {
    context.read<CreateScheduleStore>().googleMapController = controller;
  }

  bool _isPlaceForRecommendFound = true;
  Future<void> _getPlaceRecommendForUserLoc() async {
    // 버튼 누를때마다 유저의 위치를 가져오도록 하고싶지만
    // 그렇게 하면 버튼 눌림이 씹히는 현상이 있어 삭제함
    // await _getUserLoc();

    try {
      context.read<CreateScheduleStore>().setPlaceRecommendPoint(
          LatLng(_userPosition.latitude, _userPosition.longitude));
    } catch (e) {
      setState(() {
        _isPlaceForRecommendFound = false;
        return;
      });
    }
    await _createPlaceRecommendMarker();
  }

  Future<void> _getPlaceRecommendUsingOtherPlace() async {
    int indexOfScheduleHasPlace =
        context.read<CreateScheduleStore>().checkAndGetIndexForPlaceRecommend();

    try {
      context.read<CreateScheduleStore>().setPlaceRecommendPoint(context
          .read<CreateScheduleStore>()
          .scheduleList[indexOfScheduleHasPlace]
          .place!);
    } catch (e) {
      setState(() {
        _isPlaceForRecommendFound = false;
        return;
      });
    }
    await _createPlaceRecommendMarker();
  }

  Future<void> _getPlaceRecommendUsingSearchedPlace() async {
    setState(() {
      _isSearchFound = false;
    });
    await _createPlaceRecommendMarker();
  }

  Future<void> _createPlaceRecommendMarker() async {
    setState(() {
      convex = [[], [], [], [], []];
    });
    _clearMarker();

    List recommendedPlaces = await _fetchPlaceRecommend(context
        .read<CreateScheduleStore>()
        .scheduleList[
            context.read<CreateScheduleStore>().indexOfPlaceDecidingSchedule]
        .placeType);

    /// 별점 역순으로 정렬해서
    /// MarkerWindow를 별점순으로 겹치게끔 함 (추후 Stack되므로 역순정렬)
    for (int i = 0; i < recommendedPlaces.length; i++) {
      for (int j = i + 1; j < recommendedPlaces.length; j++) {
        double ratingI = recommendedPlaces[i]["rating"].toString() != "-"
            ? (recommendedPlaces[i]["rating"].runtimeType == int
                ? recommendedPlaces[i]["rating"].toDouble()
                : recommendedPlaces[i]["rating"])
            : 0.0;
        double ratingJ = recommendedPlaces[j]["rating"].toString() != "-"
            ? (recommendedPlaces[j]["rating"].runtimeType == int
                ? recommendedPlaces[j]["rating"].toDouble()
                : recommendedPlaces[j]["rating"])
            : 0.0;

        if (ratingI < ratingJ) {
          var temp = recommendedPlaces[i];
          recommendedPlaces[i] = recommendedPlaces[j];
          recommendedPlaces[j] = temp;
        }
      }
    }

    Map<MarkerId, Marker> createdMarkers = {};
    for (Map place in recommendedPlaces) {
      MarkerId markerId = MarkerId(place["place_id"]);
      createdMarkers[markerId] = await _createMarker(
          LatLng(double.parse(place["lat"]), double.parse(place["lng"])),
          place["name"],
          place["rating"].toString(),
          place["distance"],
          place["place_id"]);
      int convexIndex = 0;
      if (place["distance"] <= 100) {
        convexIndex = 0;
      } else if (place["distance"] <= 200) {
        convexIndex = 1;
      } else if (place["distance"] <= 500) {
        convexIndex = 2;
      } else if (place["distance"] <= 800) {
        convexIndex = 3;
      } else {
        convexIndex = 4;
      }
      setState(() {
        convex[convexIndex].add(markerId);
      });
    }

    setState(() {
      markers = context
          .read<CreateScheduleStore>()
          .onPlaceRecommened(convex, createdMarkers);
    });
  }

  // @override
  // void dispose() {
  //   context.read<CreateScheduleStore>().googleMapController?.dispose();
  //   super.dispose();
  // }

  bool _isSearchPressed = false;
  bool _isSearchFound = false;

  late Position _userPosition;
  late Future<dynamic> _autocomplete;
  late String _input;

  /// convex hull에 맞게 들어가는 2차원 List
  /// 0, 1, 2, 3, 4순으로 각각 100, 200, 500, 800, 800m 이상
  List<List<MarkerId>> convex = [[], [], [], [], []];

  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    int _indexOfPlaceDecidingSchedule =
        context.watch<CreateScheduleStore>().indexOfPlaceDecidingSchedule;

    // if (context.watch<CreateScheduleStore>().scheduleList.isNotEmpty) {
    //   bool _isPlaceSelectedForThisSchedule = context
    //           .watch<CreateScheduleStore>()
    //           .scheduleList[_indexOfPlaceDecidingSchedule]
    //           .place !=
    //       null;
    //   if (!context.watch<CreateScheduleStore>().isPlaceRecommended &&
    //       context.read<CreateScheduleStore>().googleMapController != null) {
    //     _clearMarker();
    //     if (_isPlaceSelectedForThisSchedule) {
    //       _addMarker(
    //           context
    //               .read<CreateScheduleStore>()
    //               .scheduleList[_indexOfPlaceDecidingSchedule]
    //               .place!,
    //           context
    //               .read<CreateScheduleStore>()
    //               .scheduleList[_indexOfPlaceDecidingSchedule]
    //               .placeName!,
    //           null,
    //           null,
    //           markerIdStr: context
    //               .read<CreateScheduleStore>()
    //               .scheduleList[_indexOfPlaceDecidingSchedule]
    //               .placeId!);
    //       context
    //           .read<CreateScheduleStore>()
    //           .googleMapController!
    //           .animateCamera(CameraUpdate.newLatLngZoom(
    //               context
    //                   .read<CreateScheduleStore>()
    //                   .scheduleList[_indexOfPlaceDecidingSchedule]
    //                   .place!,
    //               16));
    //     }
    //     // else {
    //     //   context
    //     //       .read<CreateScheduleStore>()
    //     //       .googleMapController!
    //     //       .animateCamera(CameraUpdate.newLatLngZoom(
    //     //           LatLng(_userPosition.latitude, _userPosition.longitude), 16));
    //     // }
    //   }
    // }

    return Column(children: [
      const SizedBox(
        height: 5,
      ),
      Visibility(
        visible: !context.watch<CreateScheduleStore>().isLookingPlaceDetail,
        child: Column(
          children: [
            CupertinoSearchTextField(
              controller: _textFieldController,
              autocorrect: false,
              onChanged: (value) {
                setState(() {
                  _input = value;
                });
              },
              onSuffixTap: () async {
                setState(() {
                  _textFieldController.clear();
                  FocusScope.of(context).unfocus();
                  _isSearchFound = false;
                  _isSearchPressed = false;
                });
              },
              onSubmitted: (value) {
                setState(() {
                  _input = value;
                  _isSearchPressed = true;
                  _isSearchFound = false;
                  _autocomplete = _fetchAutoComplete(_input);
                  _clearMarker();
                });
              },
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
      Visibility(
          visible: context.watch<CreateScheduleStore>().isPlaceRecommended,
          child: ConvexHullControl(convex: convex, setMarker: _setMarker)),
      Expanded(
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: defaultBoxRadius,
                child: Stack(
                  children: [
                    FutureBuilder<Widget>(
                      future: _buildGoogleMap(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!;
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 5,
                      top: 5,
                      child: context
                              .watch<CreateScheduleStore>()
                              .scheduleList
                              .isNotEmpty
                          ? Row(
                              children: [
                                UnconstrainedBox(
                                  child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: context
                                              .read<CreateScheduleStore>()
                                              .scheduleList[
                                                  _indexOfPlaceDecidingSchedule]
                                              .color,
                                          borderRadius: defaultBoxRadius,
                                          boxShadow: defaultBoxShadow),
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 8, 15, 8),
                                      child: Text(
                                        (context
                                                    .watch<
                                                        CreateScheduleStore>()
                                                    .scheduleList[
                                                        _indexOfPlaceDecidingSchedule]
                                                    .placeType !=
                                                "empty"
                                            ? context
                                                .watch<CreateScheduleStore>()
                                                .scheduleList[
                                                    _indexOfPlaceDecidingSchedule]
                                                .nameKor
                                            : "빈 스케줄"),
                                        style: mainFont(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: context
                                                    .watch<
                                                        CreateScheduleStore>()
                                                    .isLookingPlaceDetail
                                                ? 12
                                                : 15),
                                      )),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    )
                  ],
                )),
            if (_isSearchPressed)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: FutureBuilder(
                      future: _autocomplete,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List result = jsonDecode(
                              snapshot.data!.toString())['predictions'];

                          return ListView.builder(
                            itemCount: result.length,
                            itemBuilder: (context, index) {
                              String address = result[index]['description']
                                  .split(" ")
                                  .sublist(1)
                                  .join(" ");
                              return ListTile(
                                title: Text(result[index]
                                    ['structured_formatting']['main_text']),
                                subtitle: Text(address),
                                trailing: Text(
                                  "${result[index]['distance_meters']}m",
                                  style: mainFont(
                                      color: const Color.fromARGB(201, 0, 0, 0),
                                      fontSize: 11),
                                ),
                                onTap: () async {
                                  _clearMarker();
                                  var placeDetail = await _fetchPlaceDetail(
                                      placeId: result[index]['place_id']);
                                  LatLng placeLatLng = LatLng(
                                      placeDetail['lat'], placeDetail['lng']);
                                  setState(() {
                                    _isSearchPressed = false;
                                    _isSearchFound = true;
                                  });
                                  _addMarker(
                                      placeLatLng,
                                      result[index]['structured_formatting']
                                          ['main_text'],
                                      placeDetail['rating'].toString(),
                                      null,
                                      markerIdStr: result[index]['place_id']);

                                  _textFieldController.clear();
                                  context
                                      .read<CreateScheduleStore>()
                                      .googleMapController!
                                      .moveCamera(CameraUpdate.newLatLngZoom(
                                          placeLatLng, 17));
                                  context
                                      .read<CreateScheduleStore>()
                                      .setPlaceRecommendPoint(placeLatLng);
                                },
                                style: ListTileStyle.drawer,
                              );
                            },
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        );
                      }),
                ),
              ),
            // if (context.watch<CreateScheduleStore>().isLookingPlaceDetail)
            //   Positioned.fill(
            //     child: PlaceDetail(
            //         fetchPlaceDetail: _fetchPlaceDetail,
            //         clearMarker: _clearMarker,
            //         setMarker: _setMarker,
            //         markers: markers),
            //   ),
          ],
        ),
      ),
      Visibility(
          visible: !context.watch<CreateScheduleStore>().isLookingPlaceDetail &&
              !_isSearchPressed &&
              !_isSearchFound,
          child: Column(
            children: [
              SquareButtonWithLoading(
                title: "내 위치를 중심으로 추천받기",
                futureFunction: _getPlaceRecommendForUserLoc,
                activate: true,
              ),
              SquareButtonWithLoading(
                title: "다른 스케줄 중심으로 추천받기",
                futureFunction: _getPlaceRecommendUsingOtherPlace,
                activate: context
                        .watch<CreateScheduleStore>()
                        .checkAndGetIndexForPlaceRecommend()
                        .runtimeType ==
                    int,
              ),
            ],
          )),
      Visibility(
          visible: _isSearchFound,
          child: Column(
            children: [
              SquareButtonWithLoading(
                title: "이 위치를 중심으로 추천받기",
                futureFunction: _getPlaceRecommendUsingSearchedPlace,
                activate: true,
              ),
              SquareButton(
                title: "취소",
                isCancle: true,
                activate: true,
                onPressed: () {
                  setState(() {
                    _isSearchFound = false;
                    _clearMarker();
                    context
                        .read<CreateScheduleStore>()
                        .googleMapController!
                        .animateCamera(CameraUpdate.newLatLngZoom(
                            LatLng(_userPosition.latitude,
                                _userPosition.longitude),
                            15));
                  });
                },
              ),
            ],
          )),
    ]);
  }
}

// class PlaceDetail extends StatefulWidget {
//   const PlaceDetail(
//       {Key? key,
//       required this.fetchPlaceDetail,
//       required this.clearMarker,
//       required this.setMarker,
//       required this.markers})
//       : super(key: key);

//   final Future<Map> Function({required String placeId, bool shouldGetImg})
//       fetchPlaceDetail;
//   final Function clearMarker;
//   final Function(Map<MarkerId, Marker>) setMarker;
//   final Map<MarkerId, Marker> markers;

//   @override
//   State<PlaceDetail> createState() => _PlaceDetailState();
// }

// class _PlaceDetailState extends State<PlaceDetail> {
//   Widget _detailPage(Map data) {
//     return Stack(
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
//               child: Text(
//                 data["name"],
//                 style: mainFont(fontWeight: FontWeight.w800, fontSize: 22),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.star,
//                     color: pointColor,
//                     size: 20,
//                   ),
//                   Text(
//                     data["rating"].toString(),
//                     style: mainFont(
//                         color: pointColor,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 20),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Text(
//                     "${data["user_ratings_total"].toString()}개의 리뷰",
//                     style: mainFont(
//                         color: subTextColor,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 15),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: data["reviews"].length,
//                 itemBuilder: (context, index) =>
//                     _buildReviewBox(data["reviews"][index]),
//               ),
//             ),
//             if (data["photo"].isNotEmpty)
//               const SizedBox(
//                 height: 50,
//               )
//           ],
//         ),
//         if (data["photo"].isNotEmpty)
//           DraggableScrollableSheet(
//             initialChildSize: 0.13,
//             minChildSize: 0.13,
//             maxChildSize: data["photo"].length == 1 ? 0.45 : 0.7,
//             expand: true,
//             builder: (context, scrollController) {
//               return Container(
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: defaultBoxShadow,
//                       borderRadius: defaultBoxRadius),
//                   padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
//                   child: ClipRRect(
//                     borderRadius: defaultBoxRadius,
//                     child: ListView.builder(
//                         physics: const ClampingScrollPhysics(),
//                         controller: scrollController,
//                         itemCount: data["photo"].length + 1,
//                         itemBuilder: (context, index) {
//                           if (index == 0) {
//                             return const Icon(
//                               Icons.drag_handle,
//                               color: subTextColor,
//                               size: 17,
//                             );
//                           }

//                           return Padding(
//                             padding:
//                                 EdgeInsets.only(top: (index - 1 == 0 ? 0 : 5)),
//                             child: ClipRRect(
//                               borderRadius: defaultBoxRadius,
//                               child: Image.network(
//                                 data["photo"][index - 1],
//                                 loadingBuilder:
//                                     (context, imgWidget, loadingProgress) {
//                                   if (loadingProgress == null) {
//                                     return imgWidget;
//                                   }
//                                   return Center(
//                                     child: CircularProgressIndicator(
//                                       color: primaryColor,
//                                       value:
//                                           loadingProgress.expectedTotalBytes !=
//                                                   null
//                                               ? loadingProgress
//                                                       .cumulativeBytesLoaded /
//                                                   loadingProgress
//                                                       .expectedTotalBytes!
//                                               : null,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           );
//                         }),
//                   ));
//             },
//           )
//       ],
//     );
//   }

//   Widget _buildReviewBox(Map review) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 RatingBarIndicator(
//                     itemBuilder: (context, index) => const Icon(
//                           Icons.star,
//                           color: Colors.amber,
//                         ),
//                     itemCount: 5,
//                     itemSize: 15,
//                     direction: Axis.horizontal,
//                     rating: review["rating"].toDouble()),
//                 const SizedBox(
//                   width: 5,
//                 ),
//                 UnconstrainedBox(
//                   child: Text(
//                     review["relative_time_description"],
//                     style: mainFont(color: subTextColor, fontSize: 11.5),
//                   ),
//                 )
//               ],
//             ),
//             Text(
//               review["text"],
//               style: mainFont(color: Colors.black, fontSize: 13),
//               textAlign: TextAlign.start,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//                 borderRadius: defaultBoxRadius,
//                 boxShadow: defaultBoxShadow,
//                 color: Colors.white),
//             padding: const EdgeInsets.all(8.0),
//             child: FutureBuilder<Map>(
//               future: widget.fetchPlaceDetail(
//                   placeId: context.read<CreateScheduleStore>().selectedPlaceId,
//                   shouldGetImg: true),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   return Column(
//                     children: [
//                       Expanded(child: _detailPage(snapshot.data!)),
//                       SquareButton(
//                         title: "이 장소로 결정",
//                         onPressed: () async {
//                           await widget.clearMarker();
//                           context
//                               .read<CreateScheduleStore>()
//                               .setPlaceForSchedule();
//                           widget.setMarker({
//                             MarkerId(context
//                                     .read<CreateScheduleStore>()
//                                     .selectedPlaceId):
//                                 widget.markers[MarkerId(context
//                                     .read<CreateScheduleStore>()
//                                     .selectedPlaceId)]!
//                           });
//                         },
//                         activate: true,
//                       )
//                     ],
//                   );
//                 }
//                 return const Center(
//                   child: CircularProgressIndicator(
//                     color: primaryColor,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         Positioned(
//             top: 3,
//             right: 3,
//             child: IconButton(
//                 onPressed: () => context
//                     .read<CreateScheduleStore>()
//                     .onLookingPlaceDetailEnd(),
//                 icon: const Icon(
//                   Icons.close,
//                   color: subTextColor,
//                   size: 20,
//                 )))
//       ],
//     );
//   }
// }

class ConvexHullControl extends StatefulWidget {
  const ConvexHullControl(
      {Key? key, required this.convex, required this.setMarker})
      : super(key: key);

  final List<List<MarkerId>> convex;
  final Function(Map<MarkerId, Marker>) setMarker;

  @override
  State<ConvexHullControl> createState() => _ConvexHullControlState();
}

class _ConvexHullControlState extends State<ConvexHullControl> {
  final Map<int, Widget> _convexTypes = {
    0: Text(
      '100m',
      style: mainFont(),
    ),
    1: Text(
      '200m',
      style: mainFont(),
    ),
    2: Text(
      '500m',
      style: mainFont(),
    ),
    3: Text(
      '800m',
      style: mainFont(),
    ),
    4: Column(children: [
      Text(
        '800m',
        style: mainFont(),
      ),
      Text(
        '이상',
        style: mainFont(),
      ),
    ])
  };
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSegmentedControl(
          padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          children: _convexTypes,
          groupValue: context.watch<CreateScheduleStore>().convexType,
          onValueChanged: (int convexHullIndex) async {
            context.read<CreateScheduleStore>().setConvexType(convexHullIndex);
            widget.setMarker(context
                .read<CreateScheduleStore>()
                .setConvexHullVisibility(widget.convex, convexHullIndex));
          }),
    );
  }
}
