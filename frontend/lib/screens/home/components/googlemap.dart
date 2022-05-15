import 'dart:io';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';

class Googlemap extends StatefulWidget {
  const Googlemap({Key? key}) : super(key: key);
  @override
  State<Googlemap> createState() => _GooglemapState();
}

class _GooglemapState extends State<Googlemap> {
  late GoogleMapController mapController;

  @override
  void initState() {
    _googleMap = FutureBuilder<Widget>(
        future: _buildGoogleMap(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
              color: primaryColor,
            ));
          } else {
            return snapshot.data;
          }
        });
    super.initState();
  }

  Future<Widget> _buildGoogleMap() async {
    Position tempUserPosition;
    tempUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      context.read<HomeProvider>().setUserLocation(
          LatLng(tempUserPosition.latitude, tempUserPosition.longitude));
    }

    return const GoogleMapBody();
  }

  late Widget
      _googleMap; // = Center(child: ProgressIndicator(color: primaryColor),);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: defaultBoxRadius, boxShadow: defaultBoxShadow),
      child: _googleMap,
    );
  }
}

class GoogleMapBody extends StatelessWidget {
  const GoogleMapBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, provider, widget) {
      return GoogleMap(
          onMapCreated: (controller) =>
              (context.read<HomeProvider>().mainMapController = controller),
          mapToolbarEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          markers: Set<Marker>.of(context.watch<HomeProvider>().markers.values),
          polylines:
              Set<Polyline>.of(context.watch<HomeProvider>().polylines.values),
          initialCameraPosition: CameraPosition(
              target: context.read<HomeProvider>().userLocation, zoom: 15));
    });
  }
}
