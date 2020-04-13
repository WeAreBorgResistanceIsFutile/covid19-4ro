import 'dart:core';
import 'dart:math';

import 'package:image/image.dart';

class HoughTransform {
  final Image _image;
  final int roSubunits;
  final int thetaSubunitsPerDegree;
  final int luminanceThreashold;

  int _houghMatrixRoAxisMax;
  int _houghMatrixThetaAxisMax;
  double _roUnit;

  HoughTransform(this._image, {this.roSubunits = 1, this.thetaSubunitsPerDegree = 1, this.luminanceThreashold = 150}) {
    _roUnit = (1 / roSubunits);
  }

  Image createImageFromHoughMatrix(List<List<int>> matrix) {
    Image image = Image(matrix.length, matrix[0].length);
    fill(image, getColor(0, 0, 0));

    for (var x = 0; x < image.width; x++) {
      for (var y = 0; y < image.height; y++) {
        var value = min(matrix[x][y], 255);

        image.setPixel(x, y, getColor(value, value, value));
      }
    }

    return image;
  }

  List<List<int>> calculateHoughMatrix() {
    _houghMatrixRoAxisMax = _calculateMaxRo(_image.width, _image.height) * roSubunits;
    _houghMatrixThetaAxisMax = 360 * thetaSubunitsPerDegree - 1;

    var houghMatrix = _createMatrix(_houghMatrixThetaAxisMax, _houghMatrixRoAxisMax);

    for (var x = 0; x < _image.width; x++) {
      for (var y = 0; y < _image.height; y++) {
        if (getLuminance(_image.getPixel(x, y)) > luminanceThreashold) {
          var line = _calculateRo(x, y);
          for (int thetaIndex = 0; thetaIndex < line.length; thetaIndex++) {
            int roIndex = _getRoIndex(line[thetaIndex]);
            houghMatrix[thetaIndex][roIndex]++;
          }
        }
      }
    }
    return houghMatrix;
  }

  List<double> _calculateRo(int x, int y) {
    double partOfDegree = 1 / thetaSubunitsPerDegree;
    var retVar = List.filled(_houghMatrixRoAxisMax, 0.0);
    for (var degrees = 0; degrees < 360; degrees++) {
      for (var i = 0; i < thetaSubunitsPerDegree; i++) {
        double theta = degrees + i * partOfDegree;
        retVar[degrees * thetaSubunitsPerDegree + i] = _getRoundedRo(x * cos(theta) + y * sin(theta));
      }
    }
    return retVar;
  }

  double _getRoundedRo(double ro) {
    return (ro ~/ _roUnit) * _roUnit;
  }

  int _calculateMaxRo(int imageWidht, int imageHeight) {
    return sqrt((pow(imageHeight, 2) + pow(imageWidht, 2))).round();
  }

  List<List<int>> _createMatrix(int n, int m) {
    List<List> retVar = new List<List>(n);
    for (var i = 0; i < n; i++) {
      retVar[i] = new List.filled(m, 0);
    }
    return retVar;
  }

  int _getRoIndex(double ro) {
    return (ro ~/ _roUnit).toInt();
  }
}
