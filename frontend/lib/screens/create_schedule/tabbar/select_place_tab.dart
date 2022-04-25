import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
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
    return Column(
      children: [
        const NotificationBox(
          title: "일정별 장소를 결정합니다",
        ),
        const NotificationBox(
          title: "장소가 선택된 일정이 있다면 해당 장소 주위로 장소를 추천합니다",
        ),
        Expanded(child: MapWithSearchBox()),
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
  Future<dynamic> getUserLoc() async {
    if (await Permission.location.request().isGranted) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      // 위치정보 사용 거절당했을 경우 필요하다는 다이얼로그 띄우기
      showDialog(
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
    }
  }

  /// 구글의 Autocomplete API를 사용해 자동완성 검색어를 가져오는 함수
  Future<dynamic> fetchAutoComplete(String input) async {
    final Position userLocation = await getUserLoc();
    final response = await Dio().get(
        '$commonUrl/api/placeautocomplete?input=$input&lat=${userLocation.latitude}&lng=${userLocation.longitude}');
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('서버에 문제가 발생했습니다');
    }
  }

  bool _isSearchPressed = false;
  late Future<dynamic> _autocomplete;
  late String _input;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoSearchTextField(
          onChanged: ((value) {
            setState(() {
              _input = value;
            });
          }),
          onSubmitted: (value) {
            setState(() {
              _input = value;
              _isSearchPressed = true;
              _autocomplete = fetchAutoComplete(_input);
            });
          },
        ),
        if (_isSearchPressed)
          FutureBuilder(
              future: _autocomplete,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List result =
                      jsonDecode(snapshot.data!.toString())['predictions'];

                  return Expanded(
                    child: ListView.builder(
                      itemCount: result.length,
                      itemBuilder: (context, index) {
                        String address = result[index]['description']
                            .split(" ")
                            .sublist(1)
                            .join(" ");
                        return Row(
                          children: [],
                        );

                        ListTile(
                          title: Text(result[index]['structured_formatting']
                              ['main_text']),
                          subtitle: Text(address),
                          trailing: Text(
                            "${result[index]['distance_meters']}m",
                            style: mainFont(
                                color: const Color.fromARGB(201, 0, 0, 0),
                                fontSize: 10),
                          ),
                          onTap: () => print(result[index]['place_id']),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              }),
        SquareButton(
            title: "검색",
            activate: true,
            onPressed: () {
              setState(() {
                _isSearchPressed = true;
                _autocomplete = fetchAutoComplete(_input);
              });
            })
      ],
    );
  }
}
