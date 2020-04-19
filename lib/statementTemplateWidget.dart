import 'package:camera/camera.dart';
import 'package:covid19_4ro/Model/documentTemplate.dart';
import 'package:covid19_4ro/widgets/camera.dart';
import 'package:covid19_4ro/widgets/myFloatingActionButton.dart';
import 'package:covid19_4ro/widgets/zoomableImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'documentTemplateProcessor.dart';

import 'dart:ui' as ui;

import 'localizations.dart';

class StatementTemplateWidget extends StatefulWidget {
  final DocumentTemplate _statementTemplate;

  StatementTemplateWidget(this._statementTemplate);

  @override
  StatementTemplateWidgetState createState() {
    if (_statementTemplate != null)
      return StatementTemplateWidgetState.fromStatementTemplate(_statementTemplate);
    else
      return StatementTemplateWidgetState();
  }
}

class StatementTemplateWidgetState extends State<StatementTemplateWidget> {
  DocumentTemplateProcessor documentTemplateProcessor;

  StatementTemplateWidgetState();
  StatementTemplateWidgetState.fromStatementTemplate(DocumentTemplate statementTemplate) {
    documentTemplateProcessor = DocumentTemplateProcessor.fromTemplate(statementTemplate);
  }

  @override
  Widget build(BuildContext context) {
    if (documentTemplateProcessor != null && documentTemplateProcessor.isImageLoaded) {
      _decorateImage();
    } 

    return Scaffold(
      body: Stack(
        children: <Widget>[
          documentTemplateProcessor != null && documentTemplateProcessor.isImageLoaded ? capturedImageWidget() : noImageWidget(),
          fabWidget(),
        ],
      ),
    );
  }

  Widget noImageWidget() {
    return Center(child: Icon(Icons.image, color: Colors.grey));
  }

  Widget capturedImageWidget() {
    _decorateImage();
    return SizedBox.expand(
      child: Center(child: ZoomableImage(_uiImage, userTouchedImageAt: (int x, int y) => userTouchedImage(x, y))),
    );
  }

  void userTouchedImage(int x, int y) {
    documentTemplateProcessor.selectDocumentElement(x, y);
    _decorateImage();
  }

  void increaseX() {
    documentTemplateProcessor.increaseX();
    _decorateImage();
  }

  void increaseY() {
    documentTemplateProcessor.increaseY();
    _decorateImage();
  }

  void decreaseX() {
    documentTemplateProcessor.decreaseX();
    _decorateImage();
  }

  void decreaseY() {
    documentTemplateProcessor.decreaseY();
    _decorateImage();
  }

  ui.Image _uiImage;
  void _decorateImage() {
    if (documentTemplateProcessor.isImageLoaded) {
      var imageToBeDisplayed = documentTemplateProcessor.decorateImageWithText();
      ui.decodeImageFromPixels(imageToBeDisplayed.getBytes(), imageToBeDisplayed.width, imageToBeDisplayed.height, ui.PixelFormat.rgba8888, (ui.Image img) {
        _uiImage = img;
        if (this.mounted) setState(() {});
      });
    }
  }

  void saveTemplate() {
    Navigator.pop(context, documentTemplateProcessor.documentTemplate);
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
    if (documentTemplateProcessor != null) documentTemplateProcessor.resetData();

    availableCameras().then((cameras) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(title: getLocalizedText('CaptureStatementTemplateTitle')),
              body: CameraWidget(cameras),
            );
          },
        ),
      );
      setState(() {
        if (result != null) {
          documentTemplateProcessor = DocumentTemplateProcessor.fromCameraImage(result['path'], result['descriptor']);
        }
      });
    });
  }

  String getLocalizedValue(String key) => AppLocalizations.of(context).translate(key);
  Text getLocalizedText(String key) => Text(getLocalizedValue(key));
}
