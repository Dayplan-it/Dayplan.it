import 'package:dayplan_it/screens/home/repository/home_repository.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HomeProvider extends ChangeNotifier {
  HomeRepository _homeRepository = HomeRepository();
  //id값이 넘어오거나 해서 있다고 가정한다.
  //변수선언
  int _id = 10;
  List<DateTime> _allSchedule = [];
  DateTime _nowDate = DateTime.now().add(Duration(days: 0));
  List<DecorationItem> _decoration_list = [];
  Map<String, List<dynamic>> _scheduledetail = {};
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(36, 127), zoom: 5.0);
  //구글맵 관련
  Map<MarkerId, Marker> _markers = {};
  Map<PolylineId, Polyline> _polylines = {};

  //Getter
  DateTime get nowDate => _nowDate;
  int get id => _id;
  List<DateTime> get allSchedule => _allSchedule;
  List<DecorationItem> get decoration_list => _decoration_list;
  Map<String, List<dynamic>> get scheduledetail => _scheduledetail;
  CameraPosition get initialLocation => _initialLocation;
  Map<MarkerId, Marker> get markers => _markers;
  Map<PolylineId, Polyline> get polylines => _polylines;

  //함수선언
  setGeom(data) {
    _markers = data["PL"];
    _polylines = data["RO"];
    _initialLocation = CameraPosition(
        target: LatLng(data["camera_point_lat"], data["camera_point_lng"]),
        zoom: 14.0);

    notifyListeners();
  }

  deleteData() {
    _scheduledetail = {};
    _markers = {};
    _polylines = {};
    notifyListeners();
  }

  selectDate(now) {
    _nowDate = now;
    //해당날자 일정 불러오기
    //스케줄페이지 초기화
    //지도 정보 초기화
    notifyListeners();
    //리파지토리 접근해서  데이터불라오기
  }

  setScheduleDetail(list) {
    _scheduledetail = list;
    notifyListeners();
  }

  //함수선언
  setallschdulelist(list) {
    _allSchedule = list;
    add_calander_deco(_allSchedule);
    notifyListeners();
    print('해당유저가 가지고 있는 모든 스케줄정보를 저장');
    print(_allSchedule);
    //리파지토리 접근해서  데이터불라오기
  }

  add_calander_deco(schedulelist) {
    for (int i = 0; i < schedulelist.length; i++) {
      decoration_list.add(DecorationItem(
          date: schedulelist[i],
          decoration:
              Icon(Icons.fiber_manual_record, color: Colors.red, size: 10)));
    }
    notifyListeners();
  }
}
