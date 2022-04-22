import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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
    print(polylines);
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
            height: devicewidth * 1.0,
            width: devicewidth * 0.8,
            child: Container(
                child: Column(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: devicewidth * 0.6,
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
                    ))
              ],
            )));
      },
    );
  }

  List<dynamic> setGeom(start, routdetail, end) {
    Map<MarkerId, Marker> markers = {};
    Map<PolylineId, Polyline> polylines = {};

    //시작점과 끝점의 marker를 저장
    List startMarker = addMarker(start, 90.0);
    List endMarker = addMarker(end, 330.0);
    markers[startMarker[0]] = startMarker[1];
    markers[endMarker[0]] = endMarker[1];

    for (int i = 0; i < routdetail.length; i++) {
      List poly = addPolyline(routdetail[i]);
      polylines[poly[0]] = poly[1];
    }

    return [markers, polylines];
  }

  /// 구글맵 폴리곤 객체, id를 반환하는 메소드
  List<dynamic> addPolyline(route) {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    //도보이동일
    if (route['travel_mode'] == "WK") {
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
      return [id, polyline];
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
      return [id, polyline];
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
