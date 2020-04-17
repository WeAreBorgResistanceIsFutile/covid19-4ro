import 'dart:collection';
import 'dart:core';
import 'dart:math';

import 'package:image/image.dart';

class HoughTransform {
  final int rhoSubunits;
  final int thetaSubunitsPerDegree;
  final int luminanceThreashold;
  final Image _image;

  int _houghMatrixRoAxisMax;
  int _houghMatrixThetaAxisMax;

  HashMap<int, double> _degreeIndex;

  HoughTransform(this._image, {this.rhoSubunits = 1, this.thetaSubunitsPerDegree = 1, this.luminanceThreashold = 150});

  final int processedImageWidth = 640;

  List<ThetaRho> getLines() {
    final imageShrinkedToPaperArea = copyResize(_image, width: processedImageWidth);
    var sobleImage = sobel(imageShrinkedToPaperArea);

    var binaryMatrix = calculateBinaryMatrix(sobleImage);
    var matrix = calculateHoughMatrix(binaryMatrix);
    matrix = nomalizeMatrix(matrix);

    var lines = _getHighestThetaRho(matrix, 180);

    var ratio = _image.width / processedImageWidth;
    return lines.map((e) => new ThetaRho(e.theta, (e.rho * ratio).toInt())).toList();
  }

  Image createImageFromHoughMatrix(List<List<int>> matrix) {
    Image image = Image(matrix.length, matrix[0].length);
    fill(image, getColor(0, 0, 0));

    for (var x = 0; x < image.width; x++) {
      for (var y = 0; y < image.height; y++) {
        var value = matrix[x][y];
        image.setPixel(x, y, getColor(value, value, value));
      }
    }

    return image;
  }

  List<ThetaRho> _getHighestThetaRho(List<List<int>> matrix, int threshold) {
    var retVar = List<ThetaRho>();

    double angleUnit = pi / (180 * thetaSubunitsPerDegree);
    _degreeIndex = _createDegreeIndex(angleUnit);
    int offset = matrix[0].length ~/ 2;
    for (var theta = 0; theta < matrix.length; theta++) {
      for (var rho = 0; rho < matrix[0].length; rho++) {
        if (matrix[theta][rho] > threshold) 
        retVar.add(new ThetaRho(_degreeIndex[theta], (rho - offset) ~/ rhoSubunits));
      }
    }
    return retVar;
  }

  List<List<int>> nomalizeMatrix(List<List<int>> matrix) {
    int max = 0;
    List<List<int>> retVar = createMatrix<int>(matrix.length, matrix[0].length, () => 0);

    for (var x = 0; x < matrix.length; x++) {
      for (var y = 0; y < matrix[0].length; y++) {
        max = max > matrix[x][y] ? max : matrix[x][y];
      }
    }

    for (var x = 0; x < matrix.length; x++) {
      for (var y = 0; y < matrix[0].length; y++) {
        retVar[x][y] = (255 * matrix[x][y]) ~/ max;
      }
    }

    return retVar;
  }

  List<List<bool>> calculateBinaryMatrix(Image image) {
    var retVar = createMatrix<bool>(image.width, image.height, () => false);

    for (var x = 0; x < image.width; x++) {
      for (var y = 0; y < image.height; y++) {
        retVar[x][y] = getLuminance(image.getPixel(x, y)) > luminanceThreashold;
      }
    }
    return retVar;
  }

  List<List<int>> calculateHoughMatrix(List<List<bool>> binaryMatrix) {
    double angleUnit = pi / (180 * thetaSubunitsPerDegree);

    _degreeIndex = _createDegreeIndex(angleUnit);

    _houghMatrixRoAxisMax = _calculateImageDiagonal(binaryMatrix.length, binaryMatrix[0].length) * rhoSubunits * 2;
    _houghMatrixThetaAxisMax = _degreeIndex.length;

    var houghMatrix = createMatrix<int>(_houghMatrixThetaAxisMax, _houghMatrixRoAxisMax, () => 0);

    for (var x = 0; x < binaryMatrix.length; x++) {
      for (var y = 0; y < binaryMatrix[0].length; y++) {
        if (binaryMatrix[x][y]) {
          var line = calculateRo(x, y);
          for (int i = 0; i < line.length; i++) {
            int ro = (line[i] + _houghMatrixRoAxisMax / 2).toInt();
            houghMatrix[i][ro]++;
          }
        }
      }
    }

    return houghMatrix;
  }

  HashMap<int, double> _createDegreeIndex(double angleUnit) {
    var retVar = HashMap<int, double>();
    int i = 0;
    for (double d = 2 * pi + (-pi / 2); d < 2 * pi + pi; d += angleUnit) {
      retVar.putIfAbsent(i++, () => d);
    }
    return retVar;
  }

  List<double> calculateRo(int x, int y) {
    var retVar = List<double>.filled(_houghMatrixThetaAxisMax, 0.0);
    for (int i = 0; i < retVar.length; i++) {
      double theta = _degreeIndex[i];
      var value = x * cos(theta) + y * sin(theta);
      retVar[i] = value;
    }
    return retVar;
  }

  int _calculateImageDiagonal(int imageWidht, int imageHeight) {
    return sqrt((pow(imageHeight, 2) + pow(imageWidht, 2))).round();
  }

  List<List<T>> createMatrix<T>(int n, int m, T defaultValue()) {
    return _generateList<List<T>>(n, () => _generateList<T>(m, () => defaultValue()));
  }

  List<T> _generateList<T>(int length, T defaultValue()) {
    return List<T>.generate(length, (index) => defaultValue(), growable: false);
  }
}

class ThetaRho {
  final double theta;
  final int rho;

  ThetaRho(this.theta, this.rho);
}
