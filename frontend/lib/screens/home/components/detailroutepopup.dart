import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dayplan_it/constants.dart';

///detail popup
///스케쥴에서 카드를 눌렀을때 자세한 경로를 띄워준다.
///@Param : Context, 시작위치, 상세경로, 도착위치, contextwidth,contextheight
///@return : 현재 Context에 popup
class Detailpopup {
  void setRouteDetail(
      context, start, routdetail, end, devicewidth, deviceheight) {
    late GoogleMapController mapController;

    List googleGeom = setGeom(start, routdetail, end);
    Map<MarkerId, Marker> markers = googleGeom[0];
    Map<PolylineId, Polyline> polylines = googleGeom[1];
    List<dynamic> detailContents = googleGeom[2];
    int len = detailContents.length;
    CameraPosition initlocation = setCamera(start);
    showPopupWindow(
      context,
      gravity: KumiPopupGravity.center,
      curve: Curves.bounceIn,
      bgColor: Colors.grey.withOpacity(0.5),
      clickOutDismiss: true,
      clickBackDismiss: true,
      customAnimation: false,
      underStatusBar: false,
      underAppBar: true,
      childFun: (pop) {
        return Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(40),
            ),
            key: GlobalKey(),
            padding: const EdgeInsets.all(10),
            height: deviceheight * 0.7,
            width: devicewidth * 0.8,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  children: [
                    Container(
                      height: deviceheight * 0.3,
                      width: devicewidth * 0.8,
                      child: GoogleMap(
                        padding: const EdgeInsets.only(left: 150),
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        initialCameraPosition: initlocation,
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                        },
                        markers: Set<Marker>.of(markers.values),
                        polylines: Set<Polyline>.of(polylines.values),
                      ),
                    ),
                    Container(
                        height: deviceheight * 0.35,
                        width: devicewidth * 0.8,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(5),
                          itemCount: len,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      onTap: () {},
                                      leading: Icon(
                                        Icons.horizontal_rule,
                                        color: detailContents[index]['icon'],
                                      ),
                                      title: Text(
                                        detailContents[index]['instruction'],
                                        style: DayplanitLogoFont(
                                            textStyle: const TextStyle(
                                                color: Color.fromARGB(
                                                    221, 72, 72, 72)),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      subtitle:
                                          Text(detailContents[index]['info']),
                                    ),
                                  ]),
                            );
                          },

                          ///구분선추가
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                        )),
                  ],
                )));
      },
    );
  }

  List<dynamic> setGeom(start, routdetail, end) {
    Map<MarkerId, Marker> markers = {};
    Map<PolylineId, Polyline> polylines = {};
    List detailContents = [];
    //시작점과 끝점의 marker를 저장
    List startMarker = addMarker(start, 90.0);
    List endMarker = addMarker(end, 330.0);
    markers[startMarker[0]] = startMarker[1];
    markers[endMarker[0]] = endMarker[1];

    for (int i = 0; i < routdetail.length; i++) {
      List poly = addPolyline(routdetail[i]);
      polylines[poly[0]] = poly[1];
      detailContents.add(poly[2]);
    }

    return [markers, polylines, detailContents];
  }

  /// 구글맵 폴리곤 객체, id를 반환하는 메소드
  List<dynamic> addPolyline(route) {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    //도보이동일
    if (route['travel_mode'] == "WK") {
      ///Geometry 저장
      List<PointLatLng> geom = polylinePoints.decodePolyline(route['polyline']);
      PolylineId id = PolylineId(route['polyline']);
      if (geom.isNotEmpty) {
        for (var point in geom) {
          LatLng temp = LatLng(point.longitude, point.latitude);
          polylineCoordinates.add(temp);
        }
      }
      Polyline polyline = Polyline(
          polylineId: id,
          color: const Color.fromARGB(255, 155, 255, 184),
          points: polylineCoordinates);

      ///Contents(자세한 설명)저장
      Map detailComments = {};
      detailComments['instruction'] = route['instruction'];
      detailComments['distance'] = route['distance'].toString() + 'km';
      detailComments['info'] = route['duration'].toString().substring(3, 5) +
          '분  ' +
          route['distance'].toString() +
          'km';
      detailComments['icon'] = const Color.fromARGB(255, 155, 255, 184);
      return [id, polyline, detailComments];
    } else {
      Color transitColor =
          _getColorFromHex(route['transit_detail']['transit_color']);
      List<PointLatLng> geom = polylinePoints.decodePolyline(route['polyline']);
      PolylineId id = PolylineId(route['polyline']);
      if (geom.isNotEmpty) {
        for (var point in geom) {
          LatLng temp = LatLng(point.longitude, point.latitude);
          polylineCoordinates.add(temp);
        }
      }
      Polyline polyline = Polyline(
          polylineId: id, color: transitColor, points: polylineCoordinates);

      ///Contents(자세한 설명)저장
      Map detailComments = {};
      detailComments['instruction'] = route['transit_detail']
              ['transit_short_name'] +
          ' ' +
          route['instruction'];
      detailComments['info'] = detailComments['duration'] =
          (int.parse(route['duration'].toString().substring(1, 2)) * 60 +
                      int.parse(route['duration'].toString().substring(3, 5)))
                  .toString() +
              '분    ' +
              route['transit_detail']['departure_stop_name'] +
              ' 승차' +
              '\n' +
              route['transit_detail']['arrival_stop_name'] +
              ' 하차';

      detailComments['transit_name'] = route['transit_detail']['transit_name'];
      detailComments['icon'] = transitColor;
      return [id, polyline, detailComments];
    }
  }

  //16진수 색상 Color객체로 변환
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    hexColor = "FF" + hexColor;

    return Color(int.parse("0x$hexColor"));
  }

  /// 구글맵 마커 객체, id를 반환하는 메소드
  List<dynamic> addMarker(point, hue) {
    MarkerId startMarkerId = MarkerId(point[2]);
    double startLat = point[0];
    double startLng = point[1];
    LatLng startPosition = LatLng(startLat, startLng);
    BitmapDescriptor startDescriptor =
        BitmapDescriptor.defaultMarkerWithHue(hue);
    Marker startMarker = Marker(
        markerId: startMarkerId,
        icon: startDescriptor,
        position: startPosition);
    return [startMarkerId, startMarker];
  }

  CameraPosition setCamera(start) {
    double lat = start[0];
    double lng = start[1];
    return CameraPosition(target: LatLng(lat, lng), zoom: 14.0);
  }
}
