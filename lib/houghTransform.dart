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

  HoughTransform(this._image, {this.rhoSubunits = 1, this.thetaSubunitsPerDegree = 10, this.luminanceThreashold = 150});

  final int processedImageWidth = 640;

  List<ThetaRho> getPageBoundaryLines() {
    final imageShrinkedToPaperArea = copyResize(_image, width: processedImageWidth);
    var sobleImage = sobel(imageShrinkedToPaperArea);

    var binaryMatrix = calculateBinaryMatrix(sobleImage);
    var matrix = calculateHoughMatrix(binaryMatrix);
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
    else{
      horizontalLines.addAll(verticalLines);
      return horizontalLines;
    }
  }

  List<ThetaRho> getAllLines() {
    final imageShrinkedToPaperArea = copyResize(_image, width: processedImageWidth);
    var sobleImage = sobel(imageShrinkedToPaperArea);

    var binaryMatrix = calculateBinaryMatrix(sobleImage);
    var matrix = calculateHoughMatrix(binaryMatrix);
    matrix = getMatrixWithLocalMaxima(matrix, 10);
    matrix = getMatrixWithLocalMaxima(matrix, 50);
    matrix = nomalizeMatrix(matrix);

    var lines = _getHighestThetaRho(matrix, 20);
    return lines;
  }

  Image getHoughSpaceImage() {
    final imageShrinkedToPaperArea = copyResize(_image, width: processedImageWidth);
    var sobleImage = sobel(imageShrinkedToPaperArea);

    var binaryMatrix = calculateBinaryMatrix(sobleImage);
    var matrix = calculateHoughMatrix(binaryMatrix);
    matrix = getMatrixWithLocalMaxima(matrix, 10);
    // matrix = getMatrixWithLocalMaxima(matrix, 50);
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

    double angleUnit = pi / (180 * thetaSubunitsPerDegree);
    _degreeIndex = _createDegreeIndex(angleUnit);
    for (var theta = 0; theta < matrix.length; theta++) {
      for (var rho = 0; rho < matrix[0].length; rho++) {
        if (matrix[theta][rho] > threshold) retVar.add(new ThetaRho(_degreeIndex[theta], (rho - _houghMatrixRoAxisMax ~/ 2) ~/ rhoSubunits));
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

    for (var x = 0; x < matrix.length; x++) {
      for (var y = 0; y < matrix[0].length; y++) {
        if (matrix[x][y] > 0 && isLocalMaxima(matrix, x, y, range)) retVar[x][y] = matrix[x][y];
      }
    }
    return retVar;
  }

  bool isLocalMaxima(List<List<int>> matrix, int xCenter, int yCenter, int range) {
    for (var x = xCenter - range; x <= xCenter + range; x++) {
      for (var y = yCenter - range; y < yCenter + range; y++) {
        if (!(x < 0 || x >= matrix.length || y < 0 || y >= matrix[0].length)) {
          if (matrix[x][y] > matrix[xCenter][yCenter]) {
            return false;
          }
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
            int ro = (line[i]).toInt();
            houghMatrix[i][ro * rhoSubunits + _houghMatrixRoAxisMax ~/ 2]++;
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
      if (sin(d).abs() < verticalThreshold)
        retVar.putIfAbsent(i++, () => d);
      else if ((1 - sin(d).abs()).abs() < horizontalThreshold) retVar.putIfAbsent(i++, () => d);
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
