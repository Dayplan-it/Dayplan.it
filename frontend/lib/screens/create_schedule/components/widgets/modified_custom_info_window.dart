import 'dart:io';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class ModifiedCustomInfoWindowController {
  /// Add custom [Widget] and [Marker]'s [LatLng] to [CustomInfoWindow] and make it visible.
  Function(Widget, LatLng)? addInfoWindow;

  /// Notifies [CustomInfoWindow] to redraw as per change in position.
  VoidCallback? onCameraMove;

  /// Hides [CustomInfoWindow].
  VoidCallback? hideInfoWindow;

  /// Shows [CustomInfoWindow].
  VoidCallback? showInfoWindow;

  /// Holds [GoogleMapController] for calculating [CustomInfoWindow] position.
  GoogleMapController? googleMapController;

  void dispose() {
    addInfoWindow = null;
    onCameraMove = null;
    hideInfoWindow = null;
    showInfoWindow = null;
    googleMapController = null;
  }
}

class ModifiedCustomInfoWindow extends StatefulWidget {
  final ModifiedCustomInfoWindowController controller;

  /// Offset to maintain space between [Marker] and [CustomInfoWindow].
  final double offset;

  /// Height of [CustomInfoWindow].
  final double height;

  /// Width of [CustomInfoWindow].
  final double width;

  const ModifiedCustomInfoWindow({
    required this.controller,
    this.offset = 50,
    this.height = 50,
    this.width = 100,
  })  : assert(controller != null),
        assert(offset != null),
        assert(offset >= 0),
        assert(height != null),
        assert(height >= 0),
        assert(width != null),
        assert(width >= 0);

  @override
  _ModifiedCustomInfoWindowState createState() =>
      _ModifiedCustomInfoWindowState();
}

class _ModifiedCustomInfoWindowState extends State<ModifiedCustomInfoWindow> {
  bool _showNow = false;
  double _leftMargin = 0;
  double _topMargin = 0;
  Widget? _child;
  LatLng? _latLng;

  @override
  void initState() {
    super.initState();
    widget.controller.addInfoWindow = _addInfoWindow;
    widget.controller.onCameraMove = _onCameraMove;
    widget.controller.hideInfoWindow = _hideInfoWindow;
    widget.controller.showInfoWindow = _showInfoWindow;
  }

  void _updateInfoWindow() async {
    // if (_latLng == null ||
    //     _child == null ||
    //     widget.controller.googleMapController == null) {
    //   return;
    // }
    ScreenCoordinate screenCoordinate = await widget
        .controller.googleMapController!
        .getScreenCoordinate(_latLng!);
    double devicePixelRatio =
        Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;
    double left =
        (screenCoordinate.x.toDouble() / devicePixelRatio) - (widget.width / 2);
    double top = (screenCoordinate.y.toDouble() / devicePixelRatio) -
        (widget.offset + widget.height);
    setState(() {
      _showNow = true;
      _leftMargin = left;
      _topMargin = top;
    });
  }

  /// Assign the [Widget] and [Marker]'s [LatLng].
  void _addInfoWindow(Widget child, LatLng latLng) {
    _child = child;
    _latLng = latLng;
    _updateInfoWindow();
  }

  /// Notifies camera movements on [GoogleMap].
  void _onCameraMove() {
    if (!_showNow) return;
    _updateInfoWindow();
  }

  /// Disables [CustomInfoWindow] visibility.
  void _hideInfoWindow() {
    setState(() {
      _showNow = false;
    });
  }

  /// Enables [CustomInfoWindow] visibility.
  void _showInfoWindow() {
    _updateInfoWindow();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _leftMargin,
      top: _topMargin,
      child: Visibility(
        visible: (_showNow == false ||
                (_leftMargin == 0 && _topMargin == 0) ||
                _child == null ||
                _latLng == null)
            ? false
            : true,
        child: SizedBox(
          child: _child,
          height: widget.height,
          width: widget.width,
        ),
      ),
    );
  }
}
