import 'package:flutter/material.dart';
import 'package:image_network/src/app_image.dart';
import 'package:image_network/src/web/box_fit_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:webviewimage/webviewimage.dart';
export 'package:image_network/src/web/box_fit_web.dart';

class ImageNetwork extends StatefulWidget {
  final String image;
  final ImageProvider? imageCache;
  final BoxFit fitAndroidIos;
  final BoxFitWeb fitWeb;
  final double height;
  final double width;
  final int duration;
  final Curve curve;
  final bool onPointer;
  final bool fullScreen;
  final bool debugPrint;
  final BorderRadius borderRadius;
  final Widget onLoading;
  final Widget onError;

  ///constructor
  ///
  ///
  const ImageNetwork({
    Key? key,
    required this.image,
    required this.height,
    required this.width,
    this.duration = 1200,
    this.curve = Curves.easeIn,
    this.onPointer = false,
    this.fitAndroidIos = BoxFit.cover,
    this.fitWeb = BoxFitWeb.cover,
    this.borderRadius = BorderRadius.zero,
    this.onLoading = const CircularProgressIndicator(),
    this.onError = const Icon(Icons.error),
    this.fullScreen = false,
    this.debugPrint = false,
    this.imageCache,
  }) : super(key: key);

  @override
  State<ImageNetwork> createState() => _ImageNetworkState();
}

class _ImageNetworkState extends State<ImageNetwork>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late WebViewXController webviewController;
  late Animation<double> _animation;

  /// bool variable used to validate (overlay with loading widget)
  /// while loading the image
  bool loading = true;

  /// bool variable used to validate (overlay with error widget)
  /// if an error occurs when loading the image
  bool error = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.duration));
    _animation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _animation,
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: WebViewX(
                  key: const ValueKey('gabriel_patrick_souza'),
                  ignoreAllGestures: true,
                  initialContent: _imagePage(
                    image: widget.image,
                    pointer: widget.onPointer,
                    fitWeb: widget.fitWeb,
                    fullScreen: widget.fullScreen,
                    height: widget.height,
                    width: widget.width,
                  ),
                  initialSourceType: SourceType.html,
                  height: widget.height,
                  width: widget.width,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller) =>
                      webviewController = controller,
                  onPageFinished: (src) {
                    if (widget.debugPrint) {
                      debugPrint('✓ The page has finished loading!\n');
                    }
                  },
                  jsContent: const {
                    EmbeddedJsContent(
                      webJs: "function onLoad(msg) { callbackLoad(msg) }",
                      mobileJs:
                          "function onLoad(msg) { callbackLoad.postMessage(msg) }",
                    ),
                    EmbeddedJsContent(
                      webJs: "function onError(msg) { callbackError(msg) }",
                      mobileJs:
                          "function onError(msg) { callbackError.postMessage(msg) }",
                    ),
                  },
                  dartCallBacks: {
                    DartCallback(
                      name: 'callbackLoad',
                      callBack: (msg) {
                        if (msg) {
                          setState(() => loading = false);
                        }
                      },
                    ),
                    DartCallback(
                      name: 'callbackError',
                      callBack: (msg) {
                        if (msg) {
                          setState(() => error = true);
                        }
                      },
                    ),
                  },
                  webSpecificParams: const WebSpecificParams(),
                  mobileSpecificParams: const MobileSpecificParams(
                    androidEnableHybridComposition: true,
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.center,
                  child: loading
                      ? SizedBox(
                          height: widget.height,
                          width: widget.width,
                          child: Center(child: widget.onLoading),
                        )
                      : Container()),
              Align(
                  alignment: Alignment.center,
                  child: error
                      ? SizedBox(
                          height: widget.height,
                          width: widget.width,
                          child: Center(child: widget.onError),
                        )
                      : Container()),
            ],
          ),
        ));
  }

  ///web page containing image only
  ///
  String _imagePage(
      {required String image,
      required bool pointer,
      required bool fullScreen,
      required double height,
      required double width,
      required BoxFitWeb fitWeb}) {
    return """<!DOCTYPE html>
            <html>
              <head>
                <style  type="text/css" rel="stylesheet">
                  body {
                    margin: 0px;
                    height: 100%;
                    width: 100%;
	                  overflow: hidden;
                   }
                    #myImg {
                      cursor: ${pointer ? "pointer" : ""};
                      transition: 0.3s;
                      width: ${fullScreen ? "100%" : "$width" "px"};
                      height: ${fullScreen ? "100%" : "$height" "px"};
                      object-fit: ${fitWeb.name(fitWeb as Fit)};
                    }
                    #myImg:hover {opacity: ${pointer ? "0.7" : ""}};}
                </style>
                <meta charset="utf-8"
                <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0">
                <meta http-equiv="Content-Security-Policy" 
                content="default-src * gap:; script-src * 'unsafe-inline' 'unsafe-eval'; connect-src *; 
                img-src * data: blob: android-webview-video-poster:; style-src * 'unsafe-inline';">
             </head>
             <body>
                <img id="myImg" src="$image" frameborder="0" allow="fullscreen"  allowfullscreen onerror= onError(this)>
                <script>
                  window.onload = function onLoad(){ callbackLoad(true);}
                </script>
             </body> 
            <script>
                function onError(source) { 
                  source.src = "https://scaffoldtecnologia.com.br/wp-content/uploads/2021/12/transparente.png";
                  source.onerror = ""; 
                  callbackError(true);
                  return true; 
                 }
            </script>
        </html>
    """;
  }
}
