import 'package:dayplan_it/screens/create_schedule/components/widgets/custom_shapes.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/google_map.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/modified_custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/buttons.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/notification_text.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/class/schedule_class.dart';

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
        MapWithSearchBox(),
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
    final response = await Dio().get(
        '$commonUrl/api/placeautocomplete?input=$input&lat=${_userPosition.latitude}&lng=${_userPosition.longitude}');
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('서버에 문제가 발생했습니다');
    }
  }

  Future<dynamic> _fetchPlaceDetail(String placeId) async {
    final response =
        await Dio().get('$commonUrl/api/placedetail?place_id=$placeId');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('서버에 문제가 발생했습니다');
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

  void _addMarker(LatLng placeLatLng, String title,
      {String markerIdStr = 'myMarker'}) {
    _onTap() {
      context.read<CreateScheduleStore>().toggleIsLookingPlaceDetail();
      print(context.read<CreateScheduleStore>().isLookingPlaceDetail);
    }

    final MarkerId markerId = MarkerId(markerIdStr);
    final Marker marker = markerWithCustomInfoWindow(
        markerId, placeLatLng, _customInfoWindowController, title, _onTap);

    // Marker(
    //   markerId: markerId,
    //   position: placeLatLng,
    //   onTap: () {
    //     _customInfoWindowController.addInfoWindow!(
    //         Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Flex(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 direction: Axis.horizontal,
    //                 children: [
    //                   Container(
    //                     alignment: Alignment.center,
    //                     padding: const EdgeInsets.all(10),
    //                     decoration: BoxDecoration(
    //                         borderRadius: defaultBoxRadius,
    //                         boxShadow: defaultBoxShadow,
    //                         color: primaryColor),
    //                     child: Row(
    //                       children: [
    //                         Text(
    //                           title,
    //                           style: mainFont(
    //                               color: Colors.white,
    //                               fontWeight: FontWeight.w600),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ]),
    //             CustomPaint(
    //               size: const Size(20, 10),
    //               painter: DrawTriangleShape(),
    //             )
    //           ],
    //         ),
    //         placeLatLng);
    //   },
    // );

    setState(() {
      markers[markerId] = marker;
    });
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
  }

  @override
  void dispose() {
    _mapController.dispose();
    _customInfoWindowController.dispose();
    super.dispose();
  }

  bool _isSearchPressed = false;
  late GoogleMapController _mapController;
  final ModifiedCustomInfoWindowController _customInfoWindowController =
      ModifiedCustomInfoWindowController();

  late Position _userPosition;
  late Future<dynamic> _autocomplete;
  late String _input;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CupertinoSearchTextField(
        autocorrect: false,
        onChanged: (value) {
          setState(() {
            _input = value;
          });
          if (value.isEmpty) {
            setState(() {
              _isSearchPressed = false;
            });
          }
        },
        onSubmitted: (value) {
          setState(() {
            _input = value;
            _isSearchPressed = true;
            _autocomplete = _fetchAutoComplete(_input);
            _clearMarker();
          });
        },
        onTap: () => _customInfoWindowController.hideAllInfoWindow!(),
      ),
      const SizedBox(
        height: 5,
      ),
      // SquareButton(
      //     title: "검색",
      //     activate: true,
      //     onPressed: () {
      //       setState(() {
      //         _isSearchPressed = true;
      //         _autocomplete = fetchAutoComplete(_input);
      //       });
      //     }),
      Expanded(
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: defaultBoxRadius,
                child: FutureBuilder<Widget>(
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
                                  });
                                  _addMarker(
                                      placeLatLng,
                                      result[index]['structured_formatting']
                                          ['main_text']);
                                  _mapController.moveCamera(
                                      CameraUpdate.newLatLng(placeLatLng));
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
      )
    ]);
  }
}
