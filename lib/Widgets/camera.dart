import 'dart:io';

import 'package:camera/camera.dart';
import 'package:covid19_4ro/Model/location.dart';
import 'package:covid19_4ro/Model/pageDescription.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraWidget extends StatefulWidget {
  final List<CameraDescription> cameras;
  CameraWidget(this.cameras);

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  PageDescription imagePageDescriptor;
  String imagePath;
  bool _toggleCamera = false;
  CameraController controller;

  @override
  void initState() {
    onCameraSelected(widget.cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Camera Found',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return Container();
    }

    List<Widget> widgets = new List<Widget>();
    widgets.add(buildCameraPreview(context));

    double markerWidth = 30;
    var pageDescriptor = buildScreenPageDescriptor();
    imagePageDescriptor = buildImagePageDescriptor(controller.value.previewSize.aspectRatio);

    widgets.add(buildRectangle(pageDescriptor.pageTopLeftLocation.x, pageDescriptor.pageTopLeftLocation.y, true, false, false, true, markerWidth));
    widgets.add(buildRectangle(pageDescriptor.pageTopRightLocation.x - markerWidth, pageDescriptor.pageTopRightLocation.y, true, true, false, false, markerWidth));
    widgets.add(buildRectangle(pageDescriptor.pageBottomLeftLocation.x, pageDescriptor.pageBottomLeftLocation.y - markerWidth, false, false, true, true, markerWidth));
    widgets.add(buildRectangle(pageDescriptor.pageBottomRightLocation.x - markerWidth, pageDescriptor.pageBottomRightLocation.y - markerWidth, false, true, true, false, markerWidth));

    pageDescriptor.getPageElements(context).forEach((e) {
      widgets.add(buildText(e.x, e.y, e.text));
    });

    widgets.add(buildLowerCommandStripe());

    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: widgets,
      ),
    );
  }

  Align buildLowerCommandStripe() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: 100.0,
        padding: EdgeInsets.all(20.0),
        color: Color.fromRGBO(0, 0, 00, 0.3),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  onTap: () {
                    _captureImage();
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 60),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  onTap: () {
                    toggleCamera();
                  },
                  child: Container(padding: EdgeInsets.all(4.0), child: _toggleCamera ? Icon(Icons.camera_front, color: Colors.white) : Icon(Icons.camera_rear, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Positioned buildText(double x, double y, String txt) {
    return Positioned(
      left: x,
      top: y,
      width: 100,
      child: Container(
        width: 100,
        height: 100,
        child: Text(txt),
      ),
    );
  }

  Positioned buildRectangle(double x, double y, bool top, bool right, bool bottom, bool left, double width) {
    return Positioned(
      left: x,
      top: y,
      width: width,
      child: Container(
        width: width,
        height: width,
        decoration: BoxDecoration(border: Border(left: buildBorderSide(left), right: buildBorderSide(right), top: buildBorderSide(top), bottom: buildBorderSide(bottom))),
      ),
    );
  }

  BorderSide buildBorderSide(bool isGreen) => BorderSide(width: 2, color: isGreen ? Colors.greenAccent : Colors.transparent);

  void toggleCamera() {
    if (!_toggleCamera) {
      onCameraSelected(widget.cameras[1]);
      setState(() {
        _toggleCamera = true;
      });
    } else {
      onCameraSelected(widget.cameras[0]);
      setState(() {
        _toggleCamera = false;
      });
    }
  }

  Transform buildCameraPreview(BuildContext context) {
    return Transform.scale(
      scale: _getImageZoom(MediaQuery.of(context), controller.value.previewSize),
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  double _getImageZoom(MediaQueryData data, Size previewSize) {
    final double logicalWidth = data.size.width;
    final double logicalHeight = previewSize.aspectRatio * logicalWidth;

    final EdgeInsets padding = data.padding;
    final double maxLogicalHeight = data.size.height - padding.top - padding.bottom;

    var ratio = maxLogicalHeight / logicalHeight;
    return ratio;
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) await controller.dispose();
    controller = CameraController(cameraDescription, ResolutionPreset.max);

    controller.addListener(() {
      if (mounted) setState(() {});      
    });

    try {
      await controller.initialize();
    } on CameraException {
    }

    if (mounted) setState(() {});
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void _captureImage() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) {
          setCameraResult();
        }
      }
    });
  }

  void setCameraResult() {
    Navigator.pop(context, {'path': imagePath, 'descriptor': imagePageDescriptor});
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {      
      return null;
    }
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/Images';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException {
      return null;
    }
    return filePath;
  }


  void logError(String code, String message) => print('Error: $code\nMessage: $message');

  PageDescription buildScreenPageDescriptor() {
    var mediaQueryResult = MediaQuery.of(context);
    double ratio = _getImageZoom(mediaQueryResult, controller.value.previewSize);

    double previewImageHeight = mediaQueryResult.size.height - mediaQueryResult.padding.top - mediaQueryResult.padding.bottom;
    double previewImageWidht = mediaQueryResult.size.width * ratio;

    double offsetX = (mediaQueryResult.size.width - previewImageWidht) / 2;
    
    double xPercentage = 0.13;
    double yPercentage = 0.05;
    double x1 = previewImageWidht * xPercentage + offsetX;
    double y1 = previewImageHeight * yPercentage;

    var pageTopLeftLocation = new Location(x1, y1);

    double x2 = x1 + previewImageWidht * (1 - xPercentage * 2);
    double y2 = y1;
    var pageTopRightLocation = new Location(x2, y2);

    double x3 = x1;
    double y3 = y1 + (x2 - x1) * (previewImageHeight / previewImageWidht) / ratio;
    var pageBottomLeftLocation = new Location(x3, y3);

    double x4 = x2;
    double y4 = y3;
    var pageBottomRightLocation = new Location(x4, y4);

    var canvasSize = new Size(mediaQueryResult.size.width, mediaQueryResult.size.height);

    PageDescription pageOnScreen = new PageDescription(pageTopLeftLocation, pageTopRightLocation, pageBottomLeftLocation, pageBottomRightLocation, canvasSize);
    return pageOnScreen;
  }

  PageDescription buildImagePageDescriptor(double aspectRatio) {
    var mediaQueryResult = MediaQuery.of(context);
    double ratio = _getImageZoom(mediaQueryResult, controller.value.previewSize);

    double previewImageHeight = mediaQueryResult.size.height - mediaQueryResult.padding.top - mediaQueryResult.padding.bottom;
    double previewImageWidht = mediaQueryResult.size.width * ratio;

    double offsetX = (mediaQueryResult.size.width - previewImageWidht) / 2;
    
    double xPercentage = 0.13;
    double yPercentage = 0.05;
    double x1 = previewImageWidht * xPercentage + offsetX + (mediaQueryResult.size.width - previewImageWidht).abs() / 2;
    double y1 = previewImageHeight * yPercentage * 2;

    var pageTopLeftLocation = new Location(x1, y1);

    double x2 = x1 + previewImageWidht * (1 - xPercentage * 2);
    double y2 = y1;
    var pageTopRightLocation = new Location(x2, y2);

    double x3 = x1;
    double y3 = y1 + (x2 - x1) * (previewImageHeight / previewImageWidht) / ratio;
    var pageBottomLeftLocation = new Location(x3, y3);

    double x4 = x2;
    double y4 = y3;
    var pageBottomRightLocation = new Location(x4, y4);

    var canvasSize = new Size(previewImageWidht, previewImageHeight);

    PageDescription pageOnScreen = new PageDescription(pageTopLeftLocation, pageTopRightLocation, pageBottomLeftLocation, pageBottomRightLocation, canvasSize);
    return pageOnScreen;
  }
}
