import 'dart:io';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class ModifiedCustomInfoWindowController {
  Function(Widget, LatLng, MarkerId)? addInfoWindow;

  VoidCallback? onCameraMove;

  Function(MarkerId)? hideInfoWindow;

  VoidCallback? hideAllInfoWindow;

  Function(MarkerId)? showInfoWindow;

  VoidCallback? showAllInfoWindow;

  VoidCallback? deleteAllInfoWindow;

  GoogleMapController? googleMapController;

  void dispose() {
    addInfoWindow = null;
    onCameraMove = null;
    hideInfoWindow = null;
    hideAllInfoWindow = null;
    showInfoWindow = null;
    showAllInfoWindow = null;
    deleteAllInfoWindow = null;
    googleMapController = null;
  }
}

class ModifiedCustomInfoWindow extends StatefulWidget {
  final ModifiedCustomInfoWindowController controller;

  final double offset;

  final double height;

  final double width;

  const ModifiedCustomInfoWindow({
    required this.controller,
    this.offset = 50,
    this.height = 50,
    this.width = 100,
  });

  @override
  _ModifiedCustomInfoWindowState createState() =>
      _ModifiedCustomInfoWindowState();
}

class _ModifiedCustomInfoWindowState extends State<ModifiedCustomInfoWindow> {
  List<Map> markerWindows = [];
  double devicePixelRatio = 1;

  @override
  void initState() {
    super.initState();
    devicePixelRatio =
        Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;
    widget.controller.addInfoWindow = _addInfoWindow;
    widget.controller.onCameraMove = _onCameraMove;
    widget.controller.hideInfoWindow = _hideInfoWindow;
    widget.controller.hideAllInfoWindow = _hideAllInfoWindow;
    widget.controller.showInfoWindow = _showInfoWindow;
    widget.controller.showAllInfoWindow = _showAllInfoWindow;
    widget.controller.deleteAllInfoWindow = _deleteAllInfoWindow;
  }

  void _updateInfoWindow() async {
    if (markerWindows.isEmpty) {
      return;
    }

    for (Map marker in markerWindows) {
      ScreenCoordinate screenCoordinate = await widget
          .controller.googleMapController!
          .getScreenCoordinate(marker["latLng"]);
      double left = (screenCoordinate.x.toDouble() / devicePixelRatio) -
          (widget.width / 2);
      double top = (screenCoordinate.y.toDouble() / devicePixelRatio) -
          (widget.offset + widget.height);

      setState(() {
        marker["showNow"] = true;
        marker["leftMargin"] = left;
        marker["topMargin"] = top;
      });
    }
  }

  void _addInfoWindow(Widget child, LatLng latLng, MarkerId markerId) {
    setState(() {
      markerWindows
          .add({"markerId": markerId, "child": child, "latLng": latLng});
      _updateInfoWindow();
    });
  }

  void _onCameraMove() {
    _updateInfoWindow();
  }

  void _hideInfoWindow(MarkerId markerId) {
    for (Map marker in markerWindows) {
      if (marker["markerId"] == markerId) {
        setState(() {
          marker["showNow"] = false;
        });
        break;
      }
    }
  }

  void _hideAllInfoWindow() {
    for (Map marker in markerWindows) {
      setState(() {
        marker["showNow"] = false;
      });
    }
  }

  void _showInfoWindow(MarkerId markerId) {
    for (Map marker in markerWindows) {
      if (marker["markerId"] == markerId) {
        setState(() {
          marker["showNow"] = true;
        });
        break;
      }
    }
  }

  void _showAllInfoWindow() {
    for (Map marker in markerWindows) {
      setState(() {
        marker["showNow"] = true;
      });
    }
  }

  void _deleteAllInfoWindow() {
    setState(() {
      markerWindows = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          if (markerWindows.isNotEmpty)
            for (Map marker in markerWindows)
              Positioned(
                left: marker["leftMargin"],
                top: marker["topMargin"],
                child: Visibility(
                  visible: marker["showNow"] ?? false,
                  child: SizedBox(
                    child: marker["child"],
                    height: widget.height,
                    width: widget.width,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
