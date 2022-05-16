import 'package:dayplan_it/class/schedule_class.dart';
import 'package:dayplan_it/components/week_calander/src/models/decoration_item.dart';
import 'package:dayplan_it/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeProvider extends ChangeNotifier {
  //사용자의 모든 일정리스트로 불러옴
  List<DateTime> _allSchedule = [];
  //현재 사용자가 선택한 날짜를 나타내는 변수(default = 오늘)
  DateTime _nowDate = DateTime.now();
  List<DecorationItem> _decorationList = [];

  /// 스케줄
  late ScheduleCreated schedule;

  /// 구글맵 컨트롤러
  GoogleMapController? mainMapController;
  void setMainMapController(GoogleMapController controller) {
    mainMapController = controller;
    notifyListeners();
  }

  /// 유저위치
  late LatLng _userLocation;

  /// 지도 로딩여부 확인용 변수
  bool isDateNewlySelected = false;
  void onDateNewlySelectedStart() {
    isDateNewlySelected = true;
    notifyListeners();
  }

  void onDateNewlySelectedEnd() {
    isDateNewlySelected = false;
    notifyListeners();
  }

  //오늘 일정 유무
  bool _hasTodaySchedule = false;
  //구글맵 geometry관련 변수
  Map<MarkerId, Marker> _markers = {};
  Map<PolylineId, Polyline> _polylines = {};
  bool _showNoSchedule = true;

  //Getter
  DateTime get nowDate => _nowDate;
  List<DateTime> get allSchedule => _allSchedule;
  List<DecorationItem> get decorationList => _decorationList;
  //Map<String, List<dynamic>> get scheduledetail => _scheduLedetail;
  LatLng get userLocation => _userLocation;
  Map<MarkerId, Marker> get markers => _markers;
  Map<PolylineId, Polyline> get polylines => _polylines;
  bool get showNoSchedule => _showNoSchedule;
  bool get hasTodaySchedule => _hasTodaySchedule;

  ///오늘 일정이 있음을 저장
  setTodaySchedule(bool a) {
    _hasTodaySchedule = a;
    notifyListeners();
  }

  /// 유저의 현 위치 저장
  setUserLocation(LatLng newUserLocation) {
    _userLocation = newUserLocation;
    notifyListeners();
  }

  ///구글맵geometry 저장 및 카메라위치 설정
  setGeom(data) {
    _markers = data["PL"];
    _polylines = data["RO"];
    mainMapController!.animateCamera(data["camera"] as CameraUpdate);
    notifyListeners();
  }

  ///비어있는 날짜를 선택시 삭제
  deleteData() {
    _markers = {};
    _polylines = {};
    mainMapController!
        .animateCamera(CameraUpdate.newLatLngZoom(_userLocation, 15));

    notifyListeners();
  }

  ///현재 선택한 날짜 설정
  selectDate(now) {
    _nowDate = now;
    notifyListeners();
  }

  ///선택한 일정의 상세정보 provider 입력
  setScheduleDetail(ScheduleCreated newSchedule) {
    schedule = newSchedule;
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
    _decorationList = [];
    for (int i = 0; i < schedulelist.length; i++) {
      _decorationList.add(DecorationItem(
          date: schedulelist[i],
          decoration: const Icon(Icons.fiber_manual_record,
              color: pointColor, size: 10)));
    }
    notifyListeners();
  }

  setNoSchedule(bool shouldShowNoSchedule) {
    _showNoSchedule = shouldShowNoSchedule;
    notifyListeners();
  }
}
