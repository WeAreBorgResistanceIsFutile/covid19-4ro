import 'package:camera/camera.dart';
import 'package:covid19_4ro/widgets/camera.dart';
import 'package:covid19_4ro/widgets/myFloatingActionButton.dart';
import 'package:covid19_4ro/widgets/zoomableImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'Model/pageDescription.dart';
import 'documentTemplateProcessor.dart';

import 'dart:ui' as ui;

class StatementTemplateWidget extends StatefulWidget {
  final DocumentTemplateProcessor documentTemplateProcessor = new DocumentTemplateProcessor();

  @override
  StatementTemplateWidgetState createState() => StatementTemplateWidgetState();
}

class StatementTemplateWidgetState extends State<StatementTemplateWidget> {
  String _imagePath;
  PageDescription _imagePageDescriptor;

  @override
  Widget build(BuildContext context) {
    if (_imagePath != null && !widget.documentTemplateProcessor.isImageLoaded) {
      widget.documentTemplateProcessor.loadImageFromCamera(context, _imagePath, _imagePageDescriptor);
      _decorateImage();
    } else if (_uiImage == null) {
      try {
        widget.documentTemplateProcessor.loadData().then((value) {
          _decorateImage();
        });
      } catch (e) {}
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          _uiImage != null ? capturedImageWidget() : noImageWidget(),
          fabWidget(),
        ],
      ),
    );
  }

  Widget noImageWidget() {
    return Center(child: Icon(Icons.image, color: Colors.grey));
  }

  Widget capturedImageWidget() {
    return SizedBox.expand(
      child: Center(child: ZoomableImage(_uiImage, userTouchedImageAt: (int x, int y) => userTouchedImage(x, y))),
    );
  }

  void userTouchedImage(int x, int y) {
    widget.documentTemplateProcessor.selectDocumentElement(x, y);
    _decorateImage();
  }

  void increaseX() {
    widget.documentTemplateProcessor.increaseX();
    _decorateImage();
  }

  void increaseY() {
    widget.documentTemplateProcessor.increaseY();
    _decorateImage();
  }

  void decreaseX() {
    widget.documentTemplateProcessor.decreaseX();
    _decorateImage();
  }

  void decreaseY() {
    widget.documentTemplateProcessor.decreaseY();
    _decorateImage();
  }

  ui.Image _uiImage;
  void _decorateImage() {
    if (widget.documentTemplateProcessor.isImageLoaded) {
      var imageToBeDisplayed = widget.documentTemplateProcessor.decorateImageWithText();

      ui.decodeImageFromPixels(imageToBeDisplayed.getBytes(), imageToBeDisplayed.width, imageToBeDisplayed.height, ui.PixelFormat.rgba8888, (ui.Image img) {
        _uiImage = img;
        setState(() {});
      });
    }
  }

  void saveTemplate() {
    widget.documentTemplateProcessor.saveData();
    Navigator.pop(context);
  }

  Widget fabWidget() {
    return Positioned(
        bottom: 30.0,
        right: 16.0,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _uiImage == null
                ? <Widget>[
                    FloatingActionButton(
                      heroTag: "btn5",
                      onPressed: openCamera,
                      child: Icon(Icons.photo_camera, color: Colors.white),
                      backgroundColor: Colors.green,
                    ),
                  ]
                : <Widget>[
                    MyFloatingActionButton(Icon(Icons.arrow_left, color: Colors.white), Colors.green, decreaseX),
                    MyFloatingActionButton(Icon(Icons.arrow_upward, color: Colors.white), Colors.green, decreaseY),
                    MyFloatingActionButton(Icon(Icons.arrow_downward, color: Colors.white), Colors.green, increaseY),
                    MyFloatingActionButton(Icon(Icons.arrow_right, color: Colors.white), Colors.green, increaseX),
                    FloatingActionButton(
                      heroTag: "btn5",
                      onPressed: saveTemplate,
                      child: Icon(Icons.save, color: Colors.white),
                      backgroundColor: Colors.green,
                    ),
                    FloatingActionButton(
                      heroTag: "btn6",
                      onPressed: openCamera,
                      child: Icon(Icons.photo_camera, color: Colors.white),
                      backgroundColor: Colors.green,
                    ),
                  ]));
  }

  Future openCamera() async {
    widget.documentTemplateProcessor.resetData();

    availableCameras().then((cameras) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Sablon foto keszitese'),
              ),
              body: CameraWidget(cameras),
            );
          },
        ),
      );
      setState(() {
        if (result != null) {
          if (_imagePath != result['path']) _uiImage = null;

          _imagePath = result['path'];
          _imagePageDescriptor = result['descriptor'];
        }
      });
    });
  }
}
