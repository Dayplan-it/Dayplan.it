import 'dart:convert';
import 'package:dayplan_it/screens/create_schedule/components/api/fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  late Widget googleMap;

  @override
  void initState() {
    _getUserLoc();
    googleMap = FutureBuilder<Widget>(
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
    );
    super.initState();
  }

  /// 기기로부터 위치정보 사용 권한을 받고 위치정보를 가져오거나
  /// AlertDialog를 띄우는 함수
  _getUserLoc() async {
    Position tempUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      context.read<CreateScheduleStore>().setUserLocation(
          LatLng(tempUserPosition.latitude, tempUserPosition.longitude));
    }
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

  Future<Widget> _buildGoogleMap() async {
    await _getUserLoc();
    return MapWithCustomInfoWindow(
      onMapCreated: _onMapCreated,
      initPosition: context.read<CreateScheduleStore>().userLocation,
    );
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
          context.read<CreateScheduleStore>().userLocation);
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
    await _createPlaceRecommendMarker();
    setState(() {
      _isSearchFound = false;
    });
  }

  Future<void> _createPlaceRecommendMarker() async {
    LatLng recommendLatLng =
        context.read<CreateScheduleStore>().placeRecommendPoint;

    context
        .read<CreateScheduleStore>()
        .googleMapController!
        .animateCamera(CameraUpdate.newLatLngZoom(recommendLatLng, 17));

    setState(() {
      convex = [[], [], [], [], []];
    });
    context.read<CreateScheduleStore>().clearMarkers();

    List recommendedPlaces = await fetchPlaceRecommend(
        placeType: context
            .read<CreateScheduleStore>()
            .scheduleList[context
                .read<CreateScheduleStore>()
                .indexOfPlaceDecidingSchedule]
            .placeType,
        position: recommendLatLng);

    Map<MarkerId, Marker> createdMarkers = {};

    createdMarkers[centertargetId] =
        await markerForCenterTarget(placeLatLng: recommendLatLng);

    for (Map place in recommendedPlaces) {
      MarkerId markerId = MarkerId(place["place_id"]);
      createdMarkers[markerId] = await markerWithCustomInfoWindow(
          context.read<CreateScheduleStore>().screenKey,
          MarkerId(place["place_id"]),
          LatLng(double.parse(place["lat"]), double.parse(place["lng"])),
          place["name"],
          place["rating"].toString(),
          place["distance"],
          isForDecidingPlace: true);
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

    context
        .read<CreateScheduleStore>()
        .onPlaceRecommened(convex, createdMarkers);
  }

  bool _isSearchPressed = false;
  bool _isSearchFound = false;

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

    return Column(children: [
      const SizedBox(
        height: 5,
      ),
      Column(
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

                _autocomplete = fetchAutoComplete(
                    input: _input,
                    position: context.read<CreateScheduleStore>().userLocation);
                context.read<CreateScheduleStore>().clearMarkers();
              });
            },
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
      Visibility(
          visible: context.watch<CreateScheduleStore>().isPlaceRecommended &&
              context
                      .watch<CreateScheduleStore>()
                      .scheduleList[context
                          .watch<CreateScheduleStore>()
                          .indexOfPlaceDecidingSchedule]
                      .placeType !=
                  'custom' &&
              !_isSearchPressed,
          child: ConvexHullControl(convex: convex)),
      Expanded(
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: defaultBoxRadius,
                child: Stack(
                  children: [
                    googleMap,
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

                          return ListView.separated(
                            separatorBuilder: (context, index) =>
                                const Divider(),
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
                                  result[index]['distance_meters'] < 1000
                                      ? "${result[index]['distance_meters']}m"
                                      : "${(result[index]['distance_meters'].toDouble() / 1000).toStringAsFixed(1)}km",
                                  style: mainFont(
                                      color: const Color.fromARGB(201, 0, 0, 0),
                                      fontSize: 11),
                                ),
                                onTap: () async {
                                  context
                                      .read<CreateScheduleStore>()
                                      .onPlaceRecommendedEnd();

                                  Map placeDetail = await fetchPlaceDetail(
                                      placeId: result[index]['place_id'],
                                      shouldGetImg: false);

                                  LatLng placeLatLng = LatLng(
                                      placeDetail['lat'], placeDetail['lng']);

                                  MarkerId markerId =
                                      MarkerId(result[index]['place_id']);

                                  context
                                      .read<CreateScheduleStore>()
                                      .setMarkers(newMarkers: {
                                    markerId: await markerWithCustomInfoWindow(
                                        context
                                            .read<CreateScheduleStore>()
                                            .screenKey,
                                        markerId,
                                        placeLatLng,
                                        result[index]['structured_formatting']
                                            ['main_text'],
                                        placeDetail['rating'].toString(),
                                        result[index]['distance_meters'],
                                        isForDecidingPlace: true)
                                  });

                                  context
                                      .read<CreateScheduleStore>()
                                      .setPlaceRecommendPoint(placeLatLng);
                                  await context
                                      .read<CreateScheduleStore>()
                                      .googleMapController!
                                      .moveCamera(CameraUpdate.newLatLngZoom(
                                          placeLatLng, 17));

                                  _textFieldController.clear();

                                  setState(() {
                                    _isSearchPressed = false;
                                    _isSearchFound = true;
                                  });
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
          ],
        ),
      ),
      Visibility(
          visible: !context.watch<CreateScheduleStore>().isLookingPlaceDetail &&
              !_isSearchPressed &&
              !_isSearchFound &&
              (context.watch<CreateScheduleStore>().scheduleList.isNotEmpty
                  ? context
                          .watch<CreateScheduleStore>()
                          .scheduleList[context
                              .watch<CreateScheduleStore>()
                              .indexOfPlaceDecidingSchedule]
                          .placeType !=
                      'custom'
                  : true),
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
                    context.read<CreateScheduleStore>().clearMarkers();
                    context
                        .read<CreateScheduleStore>()
                        .googleMapController!
                        .animateCamera(CameraUpdate.newLatLngZoom(
                            context.read<CreateScheduleStore>().userLocation,
                            15));
                  });
                },
              ),
            ],
          )),
    ]);
  }
}

class ConvexHullControl extends StatefulWidget {
  const ConvexHullControl({Key? key, required this.convex}) : super(key: key);

  final List<List<MarkerId>> convex;

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
            context
                .read<CreateScheduleStore>()
                .setConvexHullVisibility(widget.convex, convexHullIndex);
          }),
    );
  }
}
