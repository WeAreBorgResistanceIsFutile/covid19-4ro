import 'package:covid19_4ro/Model/location.dart';
import 'package:flutter/material.dart';

import '../localizations.dart';
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

  PageDescription(this.pageTopLeftLocation, this.pageTopRightLocation, this.pageBottomLeftLocation, this.pageBottomRightLocation, this.canvasSize);

  Map<String, DocumentText> _getDocumentElementsWithOnPaperCoordinates(BuildContext context) {
    return {
      firstName: DocumentText(58, 54, getLocalizedValue(context, 'firstName')),
      lastName: DocumentText(120, 54, getLocalizedValue(context, 'lastName')),
      dayOfBirth: DocumentText(58, 63, '28'),
      monthOfBirth: DocumentText(72, 63, '05'),
      yearOfBirth: DocumentText(86, 63, '1968'),
      addressLine1: DocumentText(58, 71, getLocalizedValue(context, 'addressLine1')),
      addressLine2: DocumentText(58, 79, getLocalizedValue(context, 'addressLine2')),
      destination: DocumentText(24, 106, getLocalizedValue(context, 'destination')),
      reasonOption1: DocumentText(32, 132, 'X'),
      reasonOption2: DocumentText(32, 142, 'X'),
      reasonOption3: DocumentText(32, 152, 'X'),
      reasonOption4: DocumentText(32, 161, 'X'),
      reasonOption5: DocumentText(32, 171, 'X'),
      reasonOption6: DocumentText(32, 181, 'X'),
      agriculturalActivityDescription: DocumentText(38, 182, getLocalizedValue(context, 'agriculturalActivityDescription')),
      reasonOption7: DocumentText(32, 191, 'X'),
      reasonOption8: DocumentText(32, 195, 'X'),
      reasonOption9: DocumentText(32, 202, 'X'),
      reasonOption10: DocumentText(32, 207, 'X'),
      date: DocumentText(60, 230, '30.05.2020')
    };
  }

  List<DocumentText> getPageElements(BuildContext context) => _getDocumentElementsWithOnPaperCoordinates(context).values.map((e) => _calculateCoordinates(e)).toList();

  Map<String, DocumentText> getDocumentElements(BuildContext context) {
    Map<String, DocumentText> retVar = {};
    _getDocumentElementsWithOnPaperCoordinates(context).forEach((key, value) {
      retVar[key] = _calculateCoordinates(value);
    });
    return retVar;
  }

  DocumentText _calculateCoordinates(DocumentText txt) {
    var xRatio = (pageTopRightLocation.x - pageTopLeftLocation.x) / a4Width;
    var yRatio = (pageBottomRightLocation.y - pageTopRightLocation.y) / a4Height;
    txt.x = txt.xOnPaper * xRatio + pageTopLeftLocation.x;
    txt.y = txt.yOnPaper * yRatio + pageTopLeftLocation.y;
    return txt;
  }

  String getLocalizedValue(BuildContext context, String key) => AppLocalizations.of(context).translate(key);
}
