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

  VoidCallback? updateInfoWindow;

  GoogleMapController? googleMapController;

  void dispose() {
    addInfoWindow = null;
    onCameraMove = null;
    hideInfoWindow = null;
    hideAllInfoWindow = null;
    showInfoWindow = null;
    showAllInfoWindow = null;
    deleteAllInfoWindow = null;
    updateInfoWindow = null;
    googleMapController = null;
  }
}

class ModifiedCustomInfoWindow extends StatefulWidget {
  final ModifiedCustomInfoWindowController controller;

  final double offset;

  const ModifiedCustomInfoWindow({
    required this.controller,
    this.offset = 50,
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
    widget.controller.updateInfoWindow = _updateInfoWindow;
    widget.controller.deleteAllInfoWindow = _deleteAllInfoWindow;
  }

  void _updateInfoWindow() async {
    if (markerWindows.isEmpty) {
      return;
    }

    for (int i = 0; i < markerWindows.length; i++) {
      if (markerWindows[i]["showNow"]) {
        ScreenCoordinate screenCoordinate = await widget
            .controller.googleMapController!
            .getScreenCoordinate(markerWindows[i]["latLng"]);
        double left = (screenCoordinate.x.toDouble() / devicePixelRatio);
        double top = (screenCoordinate.y.toDouble() / devicePixelRatio) -
            widget.offset -
            MediaQuery.of(context).viewInsets.bottom;

        try {
          setState(() {
            // markerWindows[i]["showNow"] = true;
            markerWindows[i]["leftMargin"] = left;
            markerWindows[i]["topMargin"] = top;
          });
        } catch (e) {
          _updateInfoWindow();
        }
      }
    }
    _refreshStackedWindows();
  }

  void _addInfoWindow(Widget child, LatLng latLng, MarkerId markerId) {
    setState(() {
      markerWindows.add({
        "markerId": markerId,
        "child": child,
        "latLng": latLng,
        "showNow": false,
      });
      _updateInfoWindow();
    });
    _refreshStackedWindows();
  }

  void _onCameraMove() {
    _updateInfoWindow();
  }

  void _hideInfoWindow(MarkerId markerId) {
    for (int i = 0; i < markerWindows.length; i++) {
      if (markerWindows[i]["markerId"] == markerId) {
        setState(() {
          markerWindows[i]["showNow"] = false;
        });
        break;
      }
    }
    _refreshStackedWindows();
  }

  void _hideAllInfoWindow() {
    for (int i = 0; i < markerWindows.length; i++) {
      setState(() {
        markerWindows[i]["showNow"] = false;
      });
    }
    _refreshStackedWindows();
  }

  void _showInfoWindow(MarkerId markerId) {
    for (int i = 0; i < markerWindows.length; i++) {
      if (markerWindows[i]["markerId"] == markerId) {
        setState(() {
          markerWindows[i]["showNow"] = true;
        });
        break;
      }
    }
    _refreshStackedWindows();
  }

  void _showAllInfoWindow() {
    for (int i = 0; i < markerWindows.length; i++) {
      setState(() {
        markerWindows[i]["showNow"] = true;
      });
    }
    _refreshStackedWindows();
  }

  void _deleteAllInfoWindow() {
    setState(() {
      markerWindows = [];
    });
    _refreshStackedWindows();
  }

  List<Widget> stackedWindows = [];

  void _refreshStackedWindows() {
    setState(() {
      stackedWindows = [];
    });
    if (markerWindows.isNotEmpty) {
      for (Map marker in markerWindows) {
        if (marker["leftMargin"] != null &&
            marker["topMargin"] != null &&
            marker["showNow"]) {
          setState(() {
            stackedWindows.add(CustomSingleChildLayout(
              delegate: CustomInfoWindowLayoutDelegate(
                left: marker["leftMargin"],
                top: marker["topMargin"],
              ),
              child: marker["child"],
            ));
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(children: stackedWindows),
    );
  }
}

class CustomInfoWindowLayoutDelegate extends SingleChildLayoutDelegate {
  final double left;
  final double top;

  CustomInfoWindowLayoutDelegate({required this.left, required this.top});

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    return this != oldDelegate;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = left - childSize.width / 2;
    double y = top - childSize.height;
    return Offset(x, y);
  }
}
