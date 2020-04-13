import 'dart:io';

import 'package:covid19_4ro/Model/address.dart';
import 'package:covid19_4ro/Model/statementOnYourLiability.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as img;

import 'Model/documentElement.dart';
import 'Model/documentText.dart';
import 'Model/pageDescription.dart';
import 'Model/person.dart';
import 'Repository/documentTextsRepository.dart';
import 'Repository/templateImageRepository.dart';
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
    final resizedImage = img.copyResize(image, width: 1024);

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
    img.drawString(image, img.arial_14, c.x.toInt(), c.y.toInt(), c.text, color: c.color);
  }

  void saveData() {
    _saveDocumentElements();
    _saveImage();
  }

  Future<bool> loadData() async {
    _image = await _loadSavedImage();
    if (_image != null) {
      initializeData(_image);
      documentElements = await _loadDocumentElements();
    }
    return _image != null;
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
