import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';

/// Place Detail을 가져오는 함수
Future<Map> fetchPlaceDetail(
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

/// 자동완성 검색어를 가져오는 함수
Future<dynamic> fetchAutoComplete(
    {required String input, required LatLng position}) async {
  try {
    final response = await Dio().get(
        '$commonUrl/api/placeautocomplete?input=$input&lat=${position.latitude}&lng=${position.longitude}&is_rankby_distance=true');
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('서버에 문제가 발생했습니다');
    }
  } catch (error) {
    rethrow;
  }
}

/// 추천받은 장소 리스트를 가져오는 함수
Future<List> fetchPlaceRecommend(
    {required String placeType, required LatLng position}) async {
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
