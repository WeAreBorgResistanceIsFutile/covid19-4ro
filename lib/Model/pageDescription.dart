import 'dart:math';

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
      lastName: DocumentText(117, 54, "dolor sit amet", 0),
      dayOfBirth: DocumentText(58, 63, '28', 0),
      monthOfBirth: DocumentText(72, 63, '05', 0),
      yearOfBirth: DocumentText(86, 63, '1968', 0),
      addressLine1: DocumentText(58, 71, "consectetur adipiscing elit", 0),
      addressLine2: DocumentText(58, 79, "sed do eiusmod tempor incididunt", 0),
      destination: DocumentText(24, 104, "ut labore et dolore magna aliqua", 0),
      reasonOption1: DocumentText(32, 130, 'X', 0),
      reasonOption2: DocumentText(32, 140, 'X', 0),
      reasonOption3: DocumentText(32, 150, 'X', 0),
      reasonOption4: DocumentText(32, 156, 'X', 0),
      reasonOption5: DocumentText(32, 166, 'X', 0),
      reasonOption6: DocumentText(32, 177, 'X', 0),
      agriculturalActivityDescription: DocumentText(38, 180, "Ut enim ad minim veniam, quis nostrud exercitation", 0),
      reasonOption7: DocumentText(32, 188, 'X', 0),
      reasonOption8: DocumentText(32, 194, 'X', 0),
      reasonOption9: DocumentText(32, 199, 'X', 0),
      reasonOption10: DocumentText(32, 203, 'X', 0),
      date: DocumentText(56, 230, '28/04/2020', 0)
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
    var x = txt.xOnPaper * xRatio + pageTopLeftLocation.x;
    var y = txt.yOnPaper * yRatio + pageTopLeftLocation.y;
    txt.x = rotateX(x, y, pi/2 - rotationAngle);
    txt.y = rotateY(x, y, pi/2 - rotationAngle);
    txt.rotationAngle = rotationAngle;
    return txt;
  }

  //https://en.wikipedia.org/wiki/Rotation_of_axes
  double rotateY(double x, double y, double theta) => -x * sin(theta) + y * cos(theta);
  double rotateX(double x, double y, double theta) => x * cos(theta) + y * sin(theta);
}
