import 'dart:io';
import 'dart:math';

import 'package:covid19_4ro/Model/address.dart';
import 'package:covid19_4ro/Model/statementOnYourLiability.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as img;

import 'Fonts/arial14.dart';
import 'Model/documentElement.dart';
import 'Model/documentText.dart';
import 'Model/location.dart';
import 'Model/pageDescription.dart';
import 'Model/person.dart';
import 'Repository/documentTextsRepository.dart';
import 'Repository/templateImageRepository.dart';
import 'drawString.dart';
import 'houghTransform.dart';
import 'tanslateCoordinates.dart';

class DocumentTemplateProcessor {
  static const double Ratio = 0.75;

  Map<String, DocumentText> documentElements = {};

  img.Image _image;
  PageDescription _pageDescription;
  int _x, _y;

  get x => _x ?? 0;

  get y => _y ?? 0;

  get isImageLoaded => _image != null;

  void loadImageFromCamera(BuildContext context, String imagePath, PageDescription pageDescription) {
    final image = img.decodeImage(File(imagePath).readAsBytesSync());
    var resizedImage = img.copyResize(image, width: 1024);

    _image = resizedImage;
    pageDescription = (new TanslateCoordinates(pageDescription)).getPageDescription(resizedImage.width.toDouble(), resizedImage.height.toDouble());

    var cropImageX = pageDescription.pageTopLeftLocation.x.toInt();
    var cropImageY = pageDescription.pageTopLeftLocation.y.toInt();

    var imageShrinkedToPaperArea = img.copyCrop(_image, cropImageX, cropImageY, pageDescription.pageWidth.toInt(), pageDescription.pageHeight.toInt());

    HoughTransform ht = HoughTransform(imageShrinkedToPaperArea, thetaSubunitsPerDegree: 20, rhoSubunits: 1, luminanceThreashold: 200);

    var lines = ht.getLines();
    if (lines.length == 4) {
      var theta = lines[2].theta;
      var locations = lines.map((e) => getLineCoordinates(e, cropImageX, cropImageY, [0, 0, _image.width, _image.height])).toList();
      if (locations.length == 4) {
        final vline1 = locations[0];
        final vline2 = locations[1];
        final hline1 = locations[2];
        final hline2 = locations[3];

        final Location pageTopLeftLocation = Location(vline1[0].x, hline1[0].y);
        final Location pageTopRightLocation = Location(vline2[0].x, hline1[1].y);
        final Location pageBottomLeftLocation = Location(vline1[1].x, hline2[0].y);
        final Location pageBottomRightLocation = Location(vline2[1].x, hline2[1].y);

        img.drawCircle(_image, pageTopLeftLocation.x.toInt(), pageTopLeftLocation.y.toInt(), 10, img.getColor(250, 0, 0));
        img.drawCircle(_image, pageTopRightLocation.x.toInt(), pageTopRightLocation.y.toInt(), 10, img.getColor(250, 255, 0));
        img.drawCircle(_image, pageBottomLeftLocation.x.toInt(), pageBottomLeftLocation.y.toInt(), 10, img.getColor(250, 255, 255));
        img.drawCircle(_image, pageBottomRightLocation.x.toInt(), pageBottomRightLocation.y.toInt(), 10, img.getColor(0, 0, 0));

        pageDescription = PageDescription(pageTopLeftLocation, pageTopRightLocation, pageBottomLeftLocation, pageBottomRightLocation, Size(resizedImage.width.toDouble(), resizedImage.height.toDouble()), rotationAngle: theta);
        _pageDescription = (new TanslateCoordinates(pageDescription)).getPageDescription(resizedImage.width.toDouble(), resizedImage.height.toDouble());
      }
    }

    lines.forEach((e) {
      drawLinesWithOffsett(_image, e, cropImageX, cropImageY);
    });

    img.drawLine(_image, cropImageX, cropImageY, cropImageX + imageShrinkedToPaperArea.width, cropImageY, img.getColor(0, 255, 0));
    img.drawLine(_image, cropImageX, cropImageY + imageShrinkedToPaperArea.height, cropImageX + imageShrinkedToPaperArea.width, cropImageY + imageShrinkedToPaperArea.height, img.getColor(0, 255, 0));

    initializeData(resizedImage);
    _pageDescription = (new TanslateCoordinates(pageDescription)).getPageDescription(resizedImage.width.toDouble(), resizedImage.height.toDouble());
    documentElements = _pageDescription.getDocumentElements(context);
  }

  void initializeData(img.Image image) {
    _image = image;
  }

  void resetData() {
    _image = null;
    documentElements = {};
  }

  void increaseX() {
    changeCoordinate((DocumentElement e) => e.x++);
  }

  void increaseY() {
    changeCoordinate((DocumentElement e) => e.y++);
  }

  void decreaseX() {
    changeCoordinate((DocumentElement e) => e.x--);
  }

  void decreaseY() {
    changeCoordinate((DocumentElement e) => e.y--);
  }

  void changeCoordinate(Function change) {
    if (_image != null) {
      if (documentElements.values.any((element) => element.isSelected)) {
        documentElements.forEach((key, value) {
          if (value.isSelected) change(value);
        });
      } else
        documentElements.forEach((key, value) {
          change(value);
        });
    }
  }

  void selectDocumentElement(int x, int y) {
    if (_image != null) {
      _x = x;
      _y = y;

      documentElements.forEach((key, value) {
        value.selectIfNearbyOnImage(x.toDouble(), y.toDouble());
      });
    }
  }

  img.Image decorateImageWithText() {
    if (_image != null) {
      var image = _image.clone();
      img.drawCircle(image, x, y, 10, 0xFFFFFFFF);

      documentElements.forEach((key, value) {
        _drawTextOnImage(image, value);
      });

      return image;
    }
    return null;
  }

  void _drawTextOnImage(img.Image image, DocumentText c) {
    drawString(image, arial_14, c.x.toInt(), c.y.toInt(), c.text, c.rotationAngle, color: c.color); 
  }

  void saveData() {
    _saveDocumentElements();
    _saveImage();
  }

  Future<bool> loadData() async {
    _image = await _loadSavedImage();
    initializeData(_image);

    if (_image != null) {
      initializeData(_image);
      documentElements = await _loadDocumentElements();
    }
    return _image != null;
  }

  void drawLines(ThetaRho e) {
    if (cos(e.theta) != 0 && sin(e.theta) != 0) {
      var x1 = 0;
      var y1 = (-cos(e.theta) / sin(e.theta)) * x1 + (e.rho / sin(e.theta));
      var x2 = x1 + 1000;
      var y2 = (-cos(e.theta) / sin(e.theta)) * x2 + (e.rho / sin(e.theta));

      img.drawLine(_image, x1.toInt(), y1.toInt(), x2.toInt(), y2.toInt(), img.getColor(255, 0, 0));
    }
  }

  void drawLinesWithOffsett(img.Image image, ThetaRho e, int xOffset, int yOffset) {
    var x1 = 0;
    var y1 = (-cos(e.theta) / sin(e.theta)) * x1 + (e.rho / sin(e.theta));
    var x2 = x1 + 1000;
    var y2 = (-cos(e.theta) / sin(e.theta)) * x2 + (e.rho / sin(e.theta));

    img.drawLine(image, x1.toInt() + xOffset, y1.toInt() + yOffset, x2.toInt() + xOffset, y2.toInt() + yOffset, img.getColor(0, 0, 0));
  }

  List<Location> getLineCoordinates(ThetaRho e, int xOffset, int yOffset, List<int> rectangle) {
    if (cos(e.theta) != 0 && sin(e.theta) != 0) {
      var x1 = 0;
      var y1 = (-cos(e.theta) / sin(e.theta)) * x1 + (e.rho / sin(e.theta));
      var x2 = x1 + 1000;
      var y2 = (-cos(e.theta) / sin(e.theta)) * x2 + (e.rho / sin(e.theta));

      List<int> line = [x1.toInt(), y1.toInt(), x2.toInt(), y2.toInt()];
      img.clipLine(line, rectangle);

      return [Location((line[0] + xOffset).toDouble(), (line[1] + yOffset).toDouble()), Location((line[2] + xOffset).toDouble(), (line[3] + yOffset).toDouble())];
    }
    return null;
  }

  void _saveImage() {
    var repository = new TemplateImageRepository();
    repository.writeData(_image);
  }

  Future<img.Image> _loadSavedImage() async {
    var repository = new TemplateImageRepository();
    var image = await repository.readData();
    return image;
  }

  void _saveDocumentElements() {
    DocumentTextsRepository repository = new DocumentTextsRepository();
    repository.writeData(documentElements);
  }

  Future<Map<String, dynamic>> _loadDocumentElements() async {
    DocumentTextsRepository repository = new DocumentTextsRepository();
    return await repository.readData();
  }

  void initializePersponalInformation(Person person) {
    documentElements["firstName"].text = person.firstName;
    documentElements["lastName"].text = person.lastName;
    documentElements["dayOfBirth"].text = person.dayOfBirth;
    documentElements["monthOfBirth"].text = person.monthOfBirth;
    documentElements["yearOfBirth"].text = person.yearOfBirth;
  }

  void initializeAddressInformation(Address address) {
    documentElements["addressLine1"].text = address.addressLine1;
    documentElements["addressLine2"].text = address.addressLine2;
  }

  void initializeStatementInformation(StatementOnYourLiability statement) {
    documentElements["destination"].text = statement.destination;

    documentElements['reasonOption1'].text = '';
    documentElements['reasonOption2'].text = '';
    documentElements['reasonOption3'].text = '';
    documentElements['reasonOption4'].text = '';
    documentElements['reasonOption5'].text = '';
    documentElements['reasonOption6'].text = '';
    documentElements['reasonOption7'].text = '';
    documentElements['reasonOption8'].text = '';
    documentElements['reasonOption9'].text = '';
    documentElements['reasonOption10'].text = '';

    statement.reasonForTheMove.forEach((element) {
      documentElements['reasonOption$element'].text = 'X';
    });

    documentElements['agriculturalActivityDescription'].text = statement.agriculturalActivityDescription;
    DateTime dt = DateTime.now();
    documentElements['date'].text = '${dt.day}/${dt.month}/${dt.year}';
  }
}
