import 'dart:collection';
import 'dart:core';
import 'dart:math';

import 'package:canny_edge_detection/canny_edge_detection.dart';
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

  final int processedImageWidth = 160;

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

  List<ThetaRho> getAllLinesSobel() {
    final imageShrinkedToPaperArea = copyResize(_image, width: processedImageWidth);

    var sobleImage = sobel(imageShrinkedToPaperArea);

    var matrix = calculateHoughMatrix(sobleImage);
    matrix = getMatrixWithLocalMaxima(matrix, 20);
    matrix = nomalizeMatrix(matrix);

    var lines = _getHighestThetaRho(matrix, 100);
    return _getVerticalThetaRho(lines);
  }

  List<ThetaRho> getAllLinesSobelEnhanced() {
    final imageShrinkedToPaperArea = copyResize(_image, width: processedImageWidth);

    var imt = gaussianBlur(imageShrinkedToPaperArea, 2);

    var matrix = calculateBWMatrix(imt);
    matrix = getMatrixWithLocalMaxima(matrix, 5);

    var img = imageFromMatrix(matrix);

    var sobleImage = sobel(imt + img);

    matrix = calculateHoughMatrix(sobleImage);
    matrix = getMatrixWithLocalMaxima(matrix, 20);
    matrix = nomalizeMatrix(matrix);

    var lines = _getHighestThetaRho(matrix, 0);
    return _getVerticalThetaRho(lines);
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
        if (matrix[theta][rho] > threshold) retVar.add(new ThetaRho(_degreeIndex[theta], (rho - _houghMatrixRoAxisMax ~/ 2) ~/ rhoSubunits, pixelCount: matrix[theta][rho]));
      }
    }

    return retVar;
  }

  List<ThetaRho> _getHighestThetaRho2(List<List<int>> matrix, int threshold) {
    var retVar = List<ThetaRho>();

    for (var theta = 0; theta < matrix.length; theta++) {
      for (var rho = 0; rho < matrix[0].length; rho++) {
        retVar.add(new ThetaRho(_degreeIndex[theta], (rho - _houghMatrixRoAxisMax ~/ 2) ~/ rhoSubunits, pixelCount: matrix[theta][rho]));
      }
    }

    return _getVerticalThetaRho(retVar);
  }

  List<ThetaRho> _getVerticalThetaRho(List<ThetaRho> lines) {
    var oneDegree = pi / 180;
    double thetaDelta = oneDegree * 2;
    int rhoDelta = 10;
    var parallelLines = List<ThetaRho>();
    for (var i = 0; i < lines.length - 1; i++) {
      var e1 = lines[i];
      var e2 = lines[i + 1];
      if (doubleAlmostEqual(e1.theta, e2.theta, thetaDelta) && !intAlmostEqual(e1.rho, e2.rho, rhoDelta)) {
        parallelLines.add(e1);
        parallelLines.add(e2);
      }
    }

    var cos90Degree = cos(pi / 2);
    var verticalLines = List<ThetaRho>();
    for (var i = 0; i < parallelLines.length; i++) {
      var e1 = parallelLines[i];
      for (var j = i + 1; j < parallelLines.length; j++) {
        var e2 = parallelLines[j];
        if (doubleAlmostEqual(cos(e1.theta - e2.theta), cos90Degree, 0.1)) {
          if (!hasMatch(verticalLines, e1, rhoDelta, thetaDelta)) {
            verticalLines.add(e1);
          }
          if (!hasMatch(verticalLines, e2, rhoDelta, thetaDelta)) {
            verticalLines.add(e2);
          }
        }
      }
    }
    return verticalLines;
  }

  bool doubleAlmostEqual(double e1, double e2, double delta) => e1 - delta < e2 && e2 < e1 + delta;
  bool intAlmostEqual(int e1, int e2, int delta) => e1 - delta < e2 && e2 < e1 + delta;
  bool thetaRhoAlmostEqual(ThetaRho e1, ThetaRho e2, int rhoDelta, double thetaDelta) {
    if (intAlmostEqual(e1.rho, e2.rho, rhoDelta) && doubleAlmostEqual(e1.theta, e2.theta, thetaDelta)) {
      return true;
    } else if (intAlmostEqual(e1.rho.abs(), e2.rho.abs(), rhoDelta)) {
      if ((e1.theta - e2.theta).abs() / pi - (e1.theta - e2.theta).abs() ~/ pi < 0.1) {
        int rho = pow(-1, (e1.theta - e2.theta).abs() ~/ pi) * e1.rho;
        if (intAlmostEqual(rho, e2.rho, rhoDelta)) {
          return true;
        } else if ((sin(e1.theta) == 0 || sin(e1.theta) == sin(pi)) && (sin(e2.theta) == 0 || sin(e2.theta) == sin(pi))) {
          return intAlmostEqual(e1.rho, e2.rho, rhoDelta);
        }
      }
    }
    return false;
  }

  bool hasMatch(List<ThetaRho> lines, ThetaRho e1, int rhoDelta, double thetaDelta) {
    bool retVar = false;
    lines.forEach((e) => retVar = retVar || thetaRhoAlmostEqual(e, e1, rhoDelta, thetaDelta));
    return retVar;
  }

  Image imageFromMatrix(List<List<int>> matrix) {
    var img = new Image(matrix.length, matrix[0].length);
    for (int x = 0; x < img.width; x++) {
      for (int y = 0; y < img.height; y++) {
        img.setPixel(x, y, getColor(matrix[x][y], matrix[x][y], matrix[x][y]));
      }
    }
    return img;
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
        int c = image.getPixel(x, y);
        var l = (getRed(c) + getBlue(c) + getGreen(c)) ~/ 3;
        retVar[x][y] = l > luminanceThreashold;
      }
    }
    return retVar;
  }

  List<List<int>> calculateBWMatrix(Image image) {
    var retVar = createMatrix<int>(image.width, image.height, () => 0);

    for (var x = 0; x < image.width; x++) {
      for (var y = 0; y < image.height; y++) {
        int c = image.getPixel(x, y);
        var l = (getRed(c) + getBlue(c) + getGreen(c)) ~/ 3;
        retVar[x][y] = l;
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
        int c = image.getPixel(x, y);
        var l = (getRed(c) + getBlue(c) + getGreen(c)) ~/ 3;
        if (l > luminanceThreashold) {
          for (int i = 0; i < _degreeIndex.length; i++) {
            var value = x * _cosTheta[i] + y * _sinTheta[i];
            houghMatrix[i][(value * rhoSubunits).toInt() + _houghMatrixRoAxisMax ~/ 2]++;
          }
        }
      }
    }

    return houghMatrix;
  }

  List<List<int>> calculateHoughMatrixFromMatrix(List<List<int>> matrix) {
    double angleUnit = pi / (180 * thetaSubunitsPerDegree);

    _degreeIndex = _createDegreeIndex(angleUnit);
    _sinTheta = _createSinTheta(_degreeIndex);
    _cosTheta = _createCosTheta(_degreeIndex);

    _houghMatrixRoAxisMax = _calculateImageDiagonal(matrix.length, matrix[0].length) * rhoSubunits * 2;
    _houghMatrixThetaAxisMax = _degreeIndex.length;

    var houghMatrix = createMatrix<int>(_houghMatrixThetaAxisMax, _houghMatrixRoAxisMax, () => 0);

    for (var x = 0; x < matrix.length; x++) {
      for (var y = 0; y < matrix[0].length; y++) {
        if (matrix[x][y] > luminanceThreashold) {
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
    for (double d = 0; d <= pi + pi / 2; d += angleUnit) {
      retVar.putIfAbsent(i++, () => d);
      // if (sin(d).abs() < verticalThreshold) {
      //   retVar.putIfAbsent(i++, () => d);
      // } else if ((1 - sin(d).abs()).abs() < horizontalThreshold) {
      //   retVar.putIfAbsent(i++, () => d);
      // }
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

  List<List<int>> kernelEdgeDetection(Image img) {
    var maxLuminance = 0;
    var matrix = createMatrix<int>(img.width, img.height, () => -1);

    for (int x = 0; x < img.width; x++) {
      for (int y = 0; y < img.height; y++) {
        int c = img.getPixel(x, y);
        var l = (getRed(c) + getBlue(c) + getGreen(c)) ~/ 3;
        maxLuminance = l > maxLuminance ? l : 0;
        matrix[x][y] = l;
      }
    }

    return kernelEdgeDetectionOnMatrix(matrix, maxLuminance);
  }

  List<List<int>> kernelEdgeDetectionOnMatrix(List<List<int>> matrix, int maxLuminance) {
    var maxLuminance = 0;
    var filter = [-1, -1, -1, -1, 8, -1, -1, -1, -1];

    var width = matrix.length;
    var height = matrix[0].length;

    var edgeDetectedImage = createMatrix<int>(width, height, () => 0);
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        var acc = 0;
        for (var j = 0, fi = 0; j < 3; ++j) {
          var yv = min(max(y - 1 + j, 0), height - 1);
          for (var i = 0; i < 3; ++i, ++fi) {
            int xv = min(max(x - 1 + i, 0), width - 1);
            var l = matrix[xv][yv];

            l = l > maxLuminance * 0.8 ? l : 0;

            acc += l * filter[fi];
          }
        }

        if (acc >= 255) edgeDetectedImage[x][y] = 255;
      }
    }
    return edgeDetectedImage;
  }
}

class ThetaRho {
  final double theta;
  final int rho;
  final int pixelCount;

  ThetaRho(this.theta, this.rho, {this.pixelCount});
}
