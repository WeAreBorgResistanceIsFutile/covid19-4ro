import 'dart:math';

import '../Repository/documentTextsRepository.dart';
import '../Repository/templateImageRepository.dart';
import 'package:image/image.dart' as img;

import '../houghTransform.dart';
import 'address.dart';
import 'documentElement.dart';
import 'documentText.dart';
import 'location.dart';
import 'pageDescription.dart';
import 'person.dart';
import 'statementOnYourLiability.dart';

class DocumentTemplate {
  static const double Ratio = 0.75;

  bool documentTemplateLoaded = false;
  String templateName;
  img.Image image;
  Map<String, DocumentText> documentElements = {};

  int _x, _y;

  get x => _x ?? 0;
  get y => _y ?? 0;
  set x(value) => _x = value;
  set y(value) => _y = value;

  DocumentTemplate();

  DocumentTemplate.fromImage(this.image, PageDescription pageDescription) {
    this.templateName = DateTime.now().microsecondsSinceEpoch.toString();
    documentElements = pageDescription.getDocumentElements();
    documentTemplateLoaded = true;
  }

  Future<void> loadTemplate(String templateName) async {
    TemplateImageRepository templateImageRepository = TemplateImageRepository(templateName);
    DocumentTextsRepository documentTextRepository = DocumentTextsRepository(templateName);
    image = await templateImageRepository.readData();
    documentElements = await documentTextRepository.readData();
    documentTemplateLoaded = true;
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
    if (documentElements.values.any((element) => element.isSelected)) {
      documentElements.forEach((key, value) {
        if (value.isSelected) change(value);
      });
    } else
      documentElements.forEach((key, value) {
        change(value);
      });
  }

  void selectDocumentElement(int x, int y) {
    _x = x;
    _y = y;

    documentElements.forEach((key, value) {
      value.selectIfNearbyOnImage(x.toDouble(), y.toDouble());
    });
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
