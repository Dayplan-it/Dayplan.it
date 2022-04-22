import 'package:flutter/material.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;
    return Consumer<HomeProvider>(builder: (context, provider, widget) {
      Map<MarkerId, Marker> markers =
          Provider.of<HomeProvider>(context, listen: false).markers;
      Map<PolylineId, Polyline> polylines =
          Provider.of<HomeProvider>(context, listen: false).polylines;

      CameraPosition initlocation =
          Provider.of<HomeProvider>(context, listen: false).initialLocation;

      //줌하는 부분
      try {
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(initlocation));
      } catch (e) {
        null;
      }
      return Container(
          width: 0.95 * devicewidth,
          height: 0.3 * deviceheight,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.all(
              Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(71, 158, 158, 158),
                offset: Offset(4.0, 4.0),
                blurRadius: 15.0,
                spreadRadius: 1.0,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-4.0, -4.0),
                blurRadius: 15.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              heightFactor: 0.3,
              widthFactor: 2.5,
              child: GoogleMap(
                padding: const EdgeInsets.only(left: 60),
                mapType: MapType.normal,
                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                myLocationButtonEnabled: true,
                initialCameraPosition: initlocation,
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polylines.values),
              ),
            ),
          ));
    });
  }
}
