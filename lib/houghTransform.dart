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
  HashMap<int, double> _cosTheta;
  HashMap<int, double> _sinTheta;

  HoughTransform(this._image, {this.rhoSubunits = 1, this.thetaSubunitsPerDegree = 10, this.luminanceThreashold = 150});

  final int processedImageWidth = 480;

  List<ThetaRho> getPageBoundaryLines() {
    final imageShrinkedToPaperArea = copyResize(_image, width: processedImageWidth);

    var sobleImage = sobel(imageShrinkedToPaperArea);

    var matrix = calculateHoughMatrix(sobleImage);
    matrix = getMatrixWithLocalMaxima(matrix, 10);
    matrix = getMatrixWithLocalMaxima(matrix, 50);
    matrix = nomalizeMatrix(matrix);

    var lines = _getHighestThetaRho(matrix, 20);
    var ratio = _image.width / processedImageWidth;

    var horizontalLines = lines.where((e) => e.theta < pi / 4 && e.rho > 10 && e.rho < sobleImage.width - 10).map((e) => ThetaRho(e.theta, (e.rho * ratio).toInt())).toList();

    var verticalLines = lines.where((e) => e.theta > pi / 4 && e.rho > 1 && e.rho < sobleImage.height - 10).map((e) => ThetaRho(e.theta, (e.rho * ratio).toInt())).toList();

    horizontalLines.sort((a, b) => a.rho.compareTo(b.rho));
    verticalLines.sort((a, b) => a.rho.compareTo(b.rho));
    if (horizontalLines.length >= 2 && verticalLines.length >= 2)
      return [horizontalLines.first, horizontalLines.last, verticalLines.first, verticalLines.last];
    else {
      horizontalLines.addAll(verticalLines);
      return horizontalLines;
    }
  }

  List<ThetaRho> getAllLines() {
    final imageShrinkedToPaperArea = copyResize(_image, width: processedImageWidth);
    
    var sobleImage = sobel(imageShrinkedToPaperArea);

    var matrix = calculateHoughMatrix(sobleImage);
    matrix = getMatrixWithLocalMaxima(matrix, 10);
    matrix = getMatrixWithLocalMaxima(matrix, 50);
    matrix = nomalizeMatrix(matrix);

    var lines = _getHighestThetaRho(matrix, 20);
    return lines;
  }

  Image getHoughSpaceImage() {
    final imageShrinkedToPaperArea = copyResize(_image, width: processedImageWidth);
    var sobleImage = sobel(imageShrinkedToPaperArea);

    var matrix = calculateHoughMatrix(sobleImage);
    matrix = getMatrixWithLocalMaxima(matrix, 10);
    matrix = getMatrixWithLocalMaxima(matrix, 50);
    matrix = nomalizeMatrix(matrix);

    return createImageFromHoughMatrix(matrix);
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

    for (var theta = 0; theta < matrix.length; theta++) {
      for (var rho = 0; rho < matrix[0].length; rho++) {
        if (matrix[theta][rho] > threshold) retVar.add(new ThetaRho(_degreeIndex[theta], (rho - _houghMatrixRoAxisMax ~/ 2) ~/ rhoSubunits));
      }
    }

    return retVar;
  }

  List<List<int>> nomalizeMatrix(List<List<int>> matrix) {
    int max = 1;
    List<List<int>> retVar = createMatrix<int>(matrix.length, matrix[0].length, () => 0);

    for (var x = 0; x < matrix.length; x++) {
      for (var y = 0; y < matrix[0].length; y++) {
        max = max > matrix[x][y] ? max : matrix[x][y];
      }
    }
    if (max > 0) {
      for (var x = 0; x < matrix.length; x++) {
        for (var y = 0; y < matrix[0].length; y++) {
          retVar[x][y] = (255 * matrix[x][y]) ~/ max;
        }
      }
    }
    return retVar;
  }

  List<List<int>> getMatrixWithLocalMaxima(List<List<int>> matrix, int range) {
    List<List<int>> retVar = createMatrix<int>(matrix.length, matrix[0].length, () => 0);

    var lastLocalMaximaX = 0;
    var lastLocalMaximaY = 0;
    for (var x = 0; x < matrix.length; x++) {
      for (var y = 0; y < matrix[0].length; y++) {
        if (matrix[x][y] > 0 &&
            !(x - range <= lastLocalMaximaX && y - range <= lastLocalMaximaY && x + range >= lastLocalMaximaX && y + range >= lastLocalMaximaY && matrix[x][y] < retVar[lastLocalMaximaX][lastLocalMaximaY]) &&
            isLocalMaxima(matrix, x, y, range)) {
          retVar[x][y] = matrix[x][y];
          lastLocalMaximaX = x;
          lastLocalMaximaY = y;
        }
      }
    }
    return retVar;
  }

  bool isLocalMaxima(List<List<int>> matrix, int xCenter, int yCenter, int range) {
    var xStart = xCenter - range >= 0 ? xCenter - range : 0;
    var yStart = yCenter - range >= 0 ? yCenter - range : 0;
    var xEnd = xCenter + range < matrix.length ? xCenter + range : matrix.length;
    var yEnd = yCenter + range < matrix[0].length ? yCenter + range : matrix[0].length;

    for (var x = xStart; x < xEnd; x++) {
      for (var y = yStart; y < yEnd; y++) {
        if (matrix[x][y] > matrix[xCenter][yCenter]) {
          return false;
        }
      }
    }

    return true;
  }

  int getValueAt(List<List<int>> matrix, int x, int y) {
    if (x < 0 || x >= matrix.length || y < 0 || y >= matrix[0].length)
      return 0;
    else
      return matrix[x][y];
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

  List<List<int>> calculateHoughMatrix(Image image) {
    double angleUnit = pi / (180 * thetaSubunitsPerDegree);

    _degreeIndex = _createDegreeIndex(angleUnit);
    _sinTheta = _createSinTheta(_degreeIndex);
    _cosTheta = _createCosTheta(_degreeIndex);

    _houghMatrixRoAxisMax = _calculateImageDiagonal(image.width, image.height) * rhoSubunits * 2;
    _houghMatrixThetaAxisMax = _degreeIndex.length;

    var houghMatrix = createMatrix<int>(_houghMatrixThetaAxisMax, _houghMatrixRoAxisMax, () => 0);

    for (var x = 0; x < image.width; x++) {
      for (var y = 0; y < image.height; y++) {
        if (getLuminance(image.getPixel(x, y)) > luminanceThreashold) {
          for (int i = 0; i < _degreeIndex.length; i++) {
            var value = x * _cosTheta[i] + y * _sinTheta[i];
            houghMatrix[i][(value * rhoSubunits).toInt() + _houghMatrixRoAxisMax ~/ 2]++;
          }
        }
      }
    }

    return houghMatrix;
  }

  HashMap<int, double> _createDegreeIndex(double angleUnit) {
    var retVar = HashMap<int, double>();
    int i = 0;
    double verticalThreshold = 0.01;
    double horizontalThreshold = 0.001;
    for (double d = -pi; d < pi; d += angleUnit) {
      if (sin(d).abs() < verticalThreshold) {
        retVar.putIfAbsent(i++, () => d);
      } else if ((1 - sin(d).abs()).abs() < horizontalThreshold) {
        retVar.putIfAbsent(i++, () => d);
      }
    }
    return retVar;
  }

  HashMap<int, double> _createCosTheta(HashMap<int, double> degreeIndex) {
    var retVar = HashMap<int, double>();
    for (int i = 0; i < degreeIndex.keys.length; i++) {
      retVar.putIfAbsent(i, () => cos(degreeIndex[i]));
    }
    return retVar;
  }

  HashMap<int, double> _createSinTheta(HashMap<int, double> degreeIndex) {
    var retVar = HashMap<int, double>();
    for (int i = 0; i < degreeIndex.keys.length; i++) {
      retVar.putIfAbsent(i, () => sin(degreeIndex[i]));
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
