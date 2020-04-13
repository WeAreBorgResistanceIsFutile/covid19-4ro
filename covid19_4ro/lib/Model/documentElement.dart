import 'dart:math';
import 'modelBase.dart';

class DocumentElement extends ModelBase {
  double _xOnPaper;
  double _yOnPaper;
  bool isSelected = false;
  double x;
  double y;

  get xOnPaper => _xOnPaper;
  get yOnPaper => _yOnPaper;

  DocumentElement(this._xOnPaper, this._yOnPaper) : super.fromJson(null);

  DocumentElement.fromJson(Map<String, dynamic> json)
      : _xOnPaper = json['xOnPaper'],
        _yOnPaper = json['yOnPaper'],
        x = json['x'],
        y = json['y'],
        super.fromJson(null);

  @override
  Map<String, dynamic> toJson() => {'xOnPaper': _xOnPaper, 'yOnPaper': _yOnPaper, 'x': x, 'y': y};

  get color => isSelected ? 0xFF0FFF0F : 0xFF000000;

  void notSelected() {
    isSelected = false;
  }

  void selectIfNearbyOnImage(double _x, double _y) {
    isSelected = sqrt(pow(_x - (x + 7), 2) + pow(_y - (y + 7), 2)) < 15;
  }
}
