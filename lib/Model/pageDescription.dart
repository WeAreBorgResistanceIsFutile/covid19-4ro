import 'package:covid19_4ro/Model/location.dart';
import 'package:flutter/material.dart';

import 'documentText.dart';

class PageDescription {
  static const double a4Height = 298;
  static const double a4Width = 210;

  static const firstName = 'firstName';
  static const lastName = 'lastName';
  static const dayOfBirth = 'dayOfBirth';
  static const monthOfBirth = 'monthOfBirth';
  static const yearOfBirth = 'yearOfBirth';
  static const addressLine1 = 'addressLine1';
  static const addressLine2 = 'addressLine2';
  static const destination = 'destination';
  static const reasonOption1 = 'reasonOption1';
  static const reasonOption2 = 'reasonOption2';
  static const reasonOption3 = 'reasonOption3';
  static const reasonOption4 = 'reasonOption4';
  static const reasonOption5 = 'reasonOption5';
  static const reasonOption6 = 'reasonOption6';
  static const agriculturalActivityDescription = 'agriculturalActivityDescription';
  static const reasonOption7 = 'reasonOption7';
  static const reasonOption8 = 'reasonOption8';
  static const reasonOption9 = 'reasonOption9';
  static const reasonOption10 = 'reasonOption10';
  static const date = 'date';

  final Location pageTopLeftLocation;
  final Location pageTopRightLocation;
  final Location pageBottomLeftLocation;
  final Location pageBottomRightLocation;
  final Size canvasSize;
  final double rotationAngle;

  get pageWidth => pageTopRightLocation.x - pageTopLeftLocation.x;
  get pageHeight => pageBottomLeftLocation.y - pageTopLeftLocation.y;

  PageDescription(this.pageTopLeftLocation, this.pageTopRightLocation, this.pageBottomLeftLocation, this.pageBottomRightLocation, this.canvasSize, {this.rotationAngle = 0});

  Map<String, DocumentText> _getDocumentElementsWithOnPaperCoordinates() {
    return {
      firstName: DocumentText(58, 54, "Lorem ipsum", 0),
      lastName: DocumentText(120, 54, "dolor sit amet", 0),
      dayOfBirth: DocumentText(58, 63, '28', 0),
      monthOfBirth: DocumentText(72, 63, '05', 0),
      yearOfBirth: DocumentText(86, 63, '1968', 0),
      addressLine1: DocumentText(58, 71, "consectetur adipiscing elit", 0),
      addressLine2: DocumentText(58, 79, "sed do eiusmod tempor incididunt", 0),
      destination: DocumentText(24, 106, "ut labore et dolore magna aliqua", 0),
      reasonOption1: DocumentText(32, 132, 'X', 0),
      reasonOption2: DocumentText(32, 142, 'X', 0),
      reasonOption3: DocumentText(32, 152, 'X', 0),
      reasonOption4: DocumentText(32, 161, 'X', 0),
      reasonOption5: DocumentText(32, 171, 'X', 0),
      reasonOption6: DocumentText(32, 181, 'X', 0),
      agriculturalActivityDescription: DocumentText(38, 182, "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", 0),
      reasonOption7: DocumentText(32, 191, 'X', 0),
      reasonOption8: DocumentText(32, 195, 'X', 0),
      reasonOption9: DocumentText(32, 202, 'X', 0),
      reasonOption10: DocumentText(32, 207, 'X', 0)
    };
  }

  List<DocumentText> getPageElements(BuildContext context) => _getDocumentElementsWithOnPaperCoordinates().values.map((e) => _calculateCoordinates(e)).toList();

  Map<String, DocumentText> getDocumentElements() {
    Map<String, DocumentText> retVar = {};
    _getDocumentElementsWithOnPaperCoordinates().forEach((key, value) {
      retVar[key] = _calculateCoordinates(value);
    });
    return retVar;
  }

  DocumentText _calculateCoordinates(DocumentText txt) {
    var xRatio = (pageTopRightLocation.x - pageTopLeftLocation.x) / a4Width;
    var yRatio = (pageBottomRightLocation.y - pageTopRightLocation.y) / a4Height;
    txt.x = txt.xOnPaper * xRatio + pageTopLeftLocation.x;
    txt.y = txt.yOnPaper * yRatio + pageTopLeftLocation.y;
    txt.rotationAngle = rotationAngle;
    return txt;
  }
}
