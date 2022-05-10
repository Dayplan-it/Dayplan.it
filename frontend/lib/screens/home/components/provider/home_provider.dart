import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeProvider extends ChangeNotifier {
  //id값이 넘어오거나 해서 있다고 가정한다.
  //예시 데이터 id= 30
  // 밑에 변수들 Const선언하라고 파란줄 뜨는데 이부분은 상수인가?

  //사용자의 모든 일정리스트로 불러옴
  List<DateTime> _allSchedule = [];
  //현재 사용자가 선택한 날짜를 나타내는 변수(default = 오늘)
  DateTime _nowDate = DateTime.now();
  List<DecorationItem> _decorationList = [];
  //일정하나의 상세일정
  Map<String, List<dynamic>> _scheduLedetail = {};
  //오늘 일정 유무
  bool _hasTodaySchedule = false;
  //현재 선택날짜에 따른 카메라 위치(default = 남한전역)
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(36, 127), zoom: 5.0);
  //구글맵 geometry관련 변수
  Map<MarkerId, Marker> _markers = {};
  Map<PolylineId, Polyline> _polylines = {};
  bool _showNoSchedule = true;
  //Getter

  DateTime get nowDate => _nowDate;
  List<DateTime> get allSchedule => _allSchedule;
  List<DecorationItem> get decorationList => _decorationList;
  Map<String, List<dynamic>> get scheduledetail => _scheduLedetail;
  CameraPosition get initialLocation => _initialLocation;
  Map<MarkerId, Marker> get markers => _markers;
  Map<PolylineId, Polyline> get polylines => _polylines;
  bool get showNoSchedule => _showNoSchedule;
  bool get hasTodaySchedule => _hasTodaySchedule;

  ///오늘 일정이 있음을 저장
  setTodaySchedule(bool a) {
    _hasTodaySchedule = a;
    notifyListeners();
  }

  ///구글맵geometry 저장 및 카메라위치 설정
  setGeom(data) {
    _markers = data["PL"];
    _polylines = data["RO"];
    _initialLocation = CameraPosition(
        target: LatLng(data["camera_point_lat"], data["camera_point_lng"]),
        zoom: 14.0);
    notifyListeners();
  }

  ///비어있는 날짜를 선택시 삭제
  deleteData() {
    _scheduLedetail = {};
    _markers = {};
    _polylines = {};
    _initialLocation = const CameraPosition(target: LatLng(36, 127), zoom: 5.0);
    notifyListeners();
  }

  ///현재 선택한 날짜 설정
  selectDate(now) {
    _nowDate = now;
    notifyListeners();
  }

  ///선택한 일정의 상세정보 provider 입력
  setScheduleDetail(list) {
    _scheduLedetail = list;
    notifyListeners();
  }

  //사용자가 가지고 있는 모든 일정들 저장하는 함수
  setallschdulelist(list) {
    _allSchedule = list;

    addCalanderDeco(_allSchedule);
    notifyListeners();
    //리파지토리 접근해서  데이터불라오기
  }

  ///캘린더에 마커표시
  addCalanderDeco(schedulelist) {
    for (int i = 0; i < schedulelist.length; i++) {
      _decorationList.add(DecorationItem(
          date: schedulelist[i],
          decoration: const Icon(Icons.fiber_manual_record,
              color: Colors.red, size: 10)));
    }
    notifyListeners();
  }

  setNoSchedult(boo) {
    _showNoSchedule = boo;
    notifyListeners();
  }
}
