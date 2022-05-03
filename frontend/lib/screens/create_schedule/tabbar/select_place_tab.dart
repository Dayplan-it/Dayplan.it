import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/buttons.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/google_map.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/modified_custom_info_window.dart';

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
  /// 기기로부터 위치정보 사용 권한을 받고 위치정보를 가져오거나
  /// AlertDialog를 띄우는 함수
  _getUserLoc() async {
    if (await Permission.location.request().isGranted) {
      _userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      // 위치정보 사용 거절당했을 경우 필요하다는 다이얼로그 띄우기
      await showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: const Text('위치정보 요청'),
                content: const Text('데이플래닛을 사용하기 위해서는 위치정보가 필요합니다.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('거절'),
                    onPressed: () {
                      context
                          .read<CreateScheduleStore>()
                          .tabController
                          .animateTo(0);
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('설정'),
                    onPressed: () => openAppSettings(),
                  ),
                ],
              ));
      if (await Permission.location.request().isGranted) {
        _userPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      } else {
        throw Error();
      }
    }
  }

  /// 구글의 Autocomplete API를 사용해 자동완성 검색어를 가져오는 함수
  Future<dynamic> _fetchAutoComplete(String input) async {
    try {
      final response = await Dio().get(
          '$commonUrl/api/placeautocomplete?input=$input&lat=${_userPosition.latitude}&lng=${_userPosition.longitude}');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('서버에 문제가 발생했습니다');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<Map> _fetchPlaceDetail(String placeId,
      {bool shouldGetImg = false}) async {
    try {
      final response = await Dio().get(
          '$commonUrl/api/placedetail?place_id=$placeId&should_get_img=$shouldGetImg');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('서버에 문제가 발생했습니다');
      }
    } catch (error) {
      print(error);
      throw error;
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
      print(error);
      throw error;
    }
  }

  Future<Widget> _buildGoogleMap() async {
    await _getUserLoc();
    return MapWithCustomInfoWindow(
      onMapCreated: _onMapCreated,
      customInfoWindowController: _customInfoWindowController,
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
      {required String markerIdStr}) {
    final MarkerId markerId = MarkerId(markerIdStr);

    final Marker marker = _createMarker(
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

  Marker _createMarker(LatLng placeLatLng, String title, String? rating,
      int? minute, String placeId) {
    final MarkerId markerId = MarkerId(placeId);
    _onTap() async {
      context.read<CreateScheduleStore>().toggleIsLookingPlaceDetail();

      await _customInfoWindowController.googleMapController!
          .animateCamera(CameraUpdate.newLatLng(placeLatLng));

      // _customInfoWindowController.hideInfoWindow!(markerId);
      // _customInfoWindowController.updateInfoWindow!();
      context
          .read<CreateScheduleStore>()
          .setSelectedPlace(placeId, title, placeLatLng);
    }

    return markerWithCustomInfoWindow(markerId, placeLatLng,
        _customInfoWindowController, title, rating, minute, _onTap);
  }

  void _clearMarker() {
    setState(() {
      markers = <MarkerId, Marker>{};
    });
    _customInfoWindowController.deleteAllInfoWindow!();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _customInfoWindowController.googleMapController = _mapController;
    context.read<CreateScheduleStore>().customInfoWindowController =
        _customInfoWindowController;
  }

  Future<void> _getPlaceRecommendForUserLoc() async {
    // 버튼 누를때마다 유저의 위치를 가져오도록 하고싶지만
    // 그렇게 하면 버튼 눌림이 씹히는 현상이 있어 삭제함
    // await _getUserLoc();

    context.read<CreateScheduleStore>().setPlaceRecommendPoint(
        LatLng(_userPosition.latitude, _userPosition.longitude));
    await _createPlaceRecommendMarker();
  }

  Future<void> _getPlaceRecommendUsingOtherPlace() async {
    int indexOfScheduleHasPlace =
        context.read<CreateScheduleStore>().checkAndGetIndexForPlaceRecommend();

    context.read<CreateScheduleStore>().setPlaceRecommendPoint(context
        .read<CreateScheduleStore>()
        .scheduleList[indexOfScheduleHasPlace]
        .place!);
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

        if (ratingI > ratingJ) {
          var temp = recommendedPlaces[i];
          recommendedPlaces[i] = recommendedPlaces[j];
          recommendedPlaces[j] = temp;
        }
      }
    }

    Map<MarkerId, Marker> createdMarkers = {};
    for (Map place in recommendedPlaces) {
      MarkerId markerId = MarkerId(place["place_id"]);
      createdMarkers[markerId] = _createMarker(
          LatLng(double.parse(place["lat"]), double.parse(place["lng"])),
          place["name"],
          place["rating"].toString(),
          place["minute"].runtimeType == int
              ? place["minute"]
              : place["minute"].toInt(),
          place["place_id"]);
      setState(() {
        convex[[5, 10, 15, 20, 25].indexOf(place["minute"].runtimeType == int
                ? place["minute"]
                : place["minute"].toInt())]
            .add(markerId);
      });
    }

    setState(() {
      markers = context.read<CreateScheduleStore>().onPlaceRecommened(
          _customInfoWindowController, convex, createdMarkers);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _customInfoWindowController.dispose();
    super.dispose();
  }

  bool _isSearchPressed = false;
  bool _isSearchFound = false;
  late GoogleMapController _mapController;
  final ModifiedCustomInfoWindowController _customInfoWindowController =
      ModifiedCustomInfoWindowController();

  late Position _userPosition;
  late Future<dynamic> _autocomplete;
  late String _input;

  /// convex hull에 맞게 들어가는 2차원 List
  /// 0, 1, 2, 3, 4순으로 각각 5, 10, 15, 20, 25분 이상
  List<List<MarkerId>> convex = [[], [], [], [], []];

  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    int _indexOfPlaceDecidingSchedule =
        context.watch<CreateScheduleStore>().indexOfPlaceDecidingSchedule;

    if (context.watch<CreateScheduleStore>().scheduleList.isNotEmpty) {
      bool _isPlaceSelectedForThisSchedule = context
              .watch<CreateScheduleStore>()
              .scheduleList[_indexOfPlaceDecidingSchedule]
              .place !=
          null;
      if (_customInfoWindowController.deleteAllInfoWindow != null &&
          !context.watch<CreateScheduleStore>().isPlaceRecommended) {
        _clearMarker();
        if (_isPlaceSelectedForThisSchedule) {
          _addMarker(
              context
                  .read<CreateScheduleStore>()
                  .scheduleList[_indexOfPlaceDecidingSchedule]
                  .place!,
              context
                  .read<CreateScheduleStore>()
                  .scheduleList[_indexOfPlaceDecidingSchedule]
                  .placeName!,
              null,
              null,
              markerIdStr: context
                  .read<CreateScheduleStore>()
                  .scheduleList[_indexOfPlaceDecidingSchedule]
                  .placeId!);
          _mapController.animateCamera(CameraUpdate.newLatLngZoom(
              context
                  .read<CreateScheduleStore>()
                  .scheduleList[_indexOfPlaceDecidingSchedule]
                  .place!,
              16));
          _customInfoWindowController.showAllInfoWindow!();
        } else {
          _mapController.animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(_userPosition.latitude, _userPosition.longitude), 16));
        }
      }
    }

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
                });
                await Future.delayed(const Duration(milliseconds: 1100));
                _customInfoWindowController.updateInfoWindow!();
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
              onTap: () async {
                // InfoWindow의 위치를 변경해야 하는데,
                // 키보드 높이의 변경된 값을 얻으려면 약간의 딜레이가 필요함
                // 추후 퍼포먼스 보고 값을 바꿀 수 있음
                await Future.delayed(const Duration(milliseconds: 1000));
                _customInfoWindowController.updateInfoWindow!();
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
          child: ConvexHullControl(
              customInfoWindowController: _customInfoWindowController,
              convex: convex,
              setMarker: _setMarker)),
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
                                      result[index]['place_id']);
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
                                  _customInfoWindowController
                                      .showAllInfoWindow!();
                                  _textFieldController.clear();
                                  _mapController.moveCamera(
                                      CameraUpdate.newLatLngZoom(
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
            if (context.watch<CreateScheduleStore>().isLookingPlaceDetail)
              Positioned.fill(
                child: PlaceDetail(
                    fetchPlaceDetail: _fetchPlaceDetail,
                    customInfoWindowController: _customInfoWindowController,
                    clearMarker: _clearMarker),
              ),
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
                    _mapController.animateCamera(CameraUpdate.newLatLngZoom(
                        LatLng(_userPosition.latitude, _userPosition.longitude),
                        15));
                  });
                },
              ),
            ],
          )),
    ]);
  }
}

class PlaceDetail extends StatefulWidget {
  const PlaceDetail(
      {Key? key,
      required this.fetchPlaceDetail,
      required this.customInfoWindowController,
      required this.clearMarker})
      : super(key: key);

  final Future<Map> Function(String, {bool shouldGetImg}) fetchPlaceDetail;
  final ModifiedCustomInfoWindowController customInfoWindowController;
  final Function clearMarker;

  @override
  State<PlaceDetail> createState() => _PlaceDetailState();
}

class _PlaceDetailState extends State<PlaceDetail> {
  bool isLoaded = false;

  Widget _detailPage(Map data) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
              child: Text(
                data["name"],
                style: mainFont(fontWeight: FontWeight.w800, fontSize: 22),
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
                height: 50,
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
                            padding:
                                EdgeInsets.only(top: (index - 1 == 0 ? 0 : 5)),
                            child: ClipRRect(
                              borderRadius: defaultBoxRadius,
                              child: Image.network(
                                data["photo"][index - 1],
                                loadingBuilder:
                                    (context, imgWidget, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return imgWidget;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                  ));
            },
          )
      ],
    );
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: defaultBoxRadius,
              boxShadow: defaultBoxShadow,
              color: Colors.white),
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Expanded(
                child: FutureBuilder<Map>(
              future: widget.fetchPlaceDetail(
                  context.read<CreateScheduleStore>().selectedPlaceId,
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
            )),
            SquareButton(
              title: "이 장소로 결정",
              onPressed: () {
                context.read<CreateScheduleStore>().setPlaceForSchedule();
                widget.clearMarker();
                widget.customInfoWindowController.deleteAllInfoWindow!();
                setState(() {
                  isLoaded = false;
                });
              },
              activate: isLoaded,
            )
          ]),
        ),
        Positioned(
            top: 3,
            right: 3,
            child: IconButton(
                onPressed: () => context
                    .read<CreateScheduleStore>()
                    .onLookingPlaceDetailEnd(),
                icon: const Icon(
                  Icons.close,
                  color: subTextColor,
                  size: 20,
                )))
      ],
    );
  }
}

class ConvexHullControl extends StatefulWidget {
  const ConvexHullControl(
      {Key? key,
      required ModifiedCustomInfoWindowController customInfoWindowController,
      required this.convex,
      required this.setMarker})
      : _customInfoWindowController = customInfoWindowController,
        super(key: key);

  final ModifiedCustomInfoWindowController _customInfoWindowController;
  final List<List<MarkerId>> convex;
  final Function(Map<MarkerId, Marker>) setMarker;

  @override
  State<ConvexHullControl> createState() => _ConvexHullControlState();
}

class _ConvexHullControlState extends State<ConvexHullControl> {
  final Map<int, Widget> _convexTypes = {
    0: Text(
      '5분',
      style: mainFont(),
    ),
    1: Text(
      '10분',
      style: mainFont(),
    ),
    2: Text(
      '15분',
      style: mainFont(),
    ),
    3: Text(
      '20분',
      style: mainFont(),
    ),
    4: Column(children: [
      Text(
        '20분',
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
                .setConvexHullVisibility(widget._customInfoWindowController,
                    widget.convex, convexHullIndex));
          }),
    );
  }
}
