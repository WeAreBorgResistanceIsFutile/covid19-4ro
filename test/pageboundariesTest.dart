import 'dart:io';
import 'dart:math';

import 'package:covid19_4ro/Model/location.dart';
import 'package:covid19_4ro/houghTransform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';

void main() {
  int startIndex = 3;
  int endIndex = 3;

  group("Hough transform tests", () {
    test("SobelEnhanced", () async {
      var alg = "SobelEnhanced";

      DateTime t = DateTime.now();
      for (var index = startIndex; index <= endIndex; index++) {
        var fileName = 'test_image$index';
        Image img = await getImage(fileName);

        img = await getImage(fileName);

        HoughTransform ht = HoughTransform(img, thetaSubunitsPerDegree: 1);

        var lines = ht.getAllLinesSobelEnhanced();

        print("$fileName - ${lines.length}");

        var locations = lines.map((e) => getLineCoordinates(e, 0, 0, [0, 0, img.width ~/ (img.width ~/ 160), img.height ~/ (img.width ~/ 160)])).toList();
        locations = locations.where((element) => element != null).toList();

        for (var i = 0; i < locations.length; i++) {
          var e = locations[i];

          drawLine(img, (e[0].xi * img.width ~/ 160), (e[0].yi * img.width ~/ 160), (e[1].xi * img.width ~/ 160), (e[1].yi * img.width ~/ 160), getColor(255, 0, 0));
        }

        List<Location> cornerPoints = List<Location>();
        var rectangle = [0, 0, img.width ~/ (img.width ~/ 160), img.height ~/ (img.width ~/ 160)];
        for (var j = 0; j < locations.length; j++) {
          var e1 = locations[j];
          if (pointWithinRectangle(e1[0], rectangle) && pointWithinRectangle(e1[1], rectangle)) {
            for (var i = j + 1; i < locations.length; i++) {
              var e2 = locations[i];
              if (pointWithinRectangle(e2[0], rectangle) && pointWithinRectangle(e2[1], rectangle)) {
                var l = intersect(e1[0], e1[1], e2[0], e2[1]);
                if (l != null) {
                  //drawCircle(img, l.xi * img.width ~/ 160, l.yi * img.width ~/ 160, 30, getColor(255, 255, 255));
                  //print("${l.xi * img.width ~/ 160} - ${l.yi * img.width ~/ 160}");
                  if (pointWithinRectangle(l, rectangle) && pointWithinRectangle(e2[1], rectangle)) cornerPoints.add(resizeLocation(l, img.width / 160));
                }
              }
            }
          }
        }

        List<List<dynamic>> possiblePageBoundaries = List<List<dynamic>>();
        for (var i = 0; i < cornerPoints.length; i++) {
          for (var j = i + 1; j < cornerPoints.length; j++) {
            List<dynamic> r = [cornerPoints[i], cornerPoints[j], 0];
            var luminance = getRectangleLuminance(r, img);
            if (luminance != null) possiblePageBoundaries.add(luminance);
          }
        }

        possiblePageBoundaries.sort((m1, m2) => (m1[4] as double).compareTo(m2[4] as double));

        for (int x = 0; x < possiblePageBoundaries.length; x++) {
          var l = possiblePageBoundaries[x][4] as double;
          //print("${l}");
        }

        for (int x = 0; x < 4; x++) {
          var l = possiblePageBoundaries.last[x] as Location;
          //print("${l.xi} ${l.yi} ${possiblePageBoundaries.last[4]}");
          drawCircle(img, l.xi, l.yi, 10, getColor(255, 0, 0));
        }

        var f = File("alma${alg}Enhanced$index.jpg");
        await f.writeAsBytes(encodeJpg(img));
      }
      print("${alg}:  ${DateTime.now().difference(t).inMilliseconds}");
    });
  });
}

List<dynamic> getRectangleLuminance(List r, Image img) {
  var l1 = r[0] as Location;
  var l2 = r[1] as Location;

  double x1 = min<int>(l1.xi, l2.xi).toDouble();
  double y1 = min<int>(l1.yi, l2.yi).toDouble();
  double x4 = max<int>(l1.xi, l2.xi).toDouble();
  double y4 = max<int>(l1.yi, l2.yi).toDouble();

  var width = x4 - x1;
  var height = y4 - y1;

  if (!(x1 == 0 && y1 == 0) && width != 0 && height != 0) {
    double retVar = 0;
    var lum1 = getLuminance(x1            , x1 + width / 2, y1             , y1 + height / 2 , img, retVar);
    var lum2 = getLuminance(x1 + width / 2, x1 + width    , y1             , y1 + height / 2, img, retVar);
    var lum3 = getLuminance(x1            , x1 + width / 2, y1 + height / 2, y1 + height    , img, retVar);
    var lum4 = getLuminance(x1 + width / 2, x1 + width    , y1 + height / 2, y1 + height    , img, retVar);
    retVar = (lum1 + lum2 + lum3 + lum4) / 4;

    if ((((retVar - lum1).abs() / retVar) < 0.1) &&
       (((retVar - lum2).abs() / retVar) < 0.1) &&
       (((retVar - lum3).abs() / retVar) < 0.1) &&
       (((retVar - lum4).abs() / retVar) < 0.1))
      return [new Location(x1, y1), new Location(x1, y4), Location(x4, y1), Location(x4, y4), retVar];
  }
  return null;
}

double getLuminance(double x1, double width, double y1, double height, Image img, double retVar) {
  for (var x = x1; x <= width; x++) {
    for (var y = y1; y <= height; y++) {
      int c = img.getPixel(x.toInt(), y.toInt());
      var l = (getRed(c) + getBlue(c) + getGreen(c)) ~/ 3;
      retVar += l;
    }
  }
  return retVar;
}

Location resizeLocation(Location l, double ratio) {
  return new Location(l.x * ratio, l.y * ratio);
}

bool pointWithinRectangle(Location l, List<int> rectangle) {
  return rectangle[0] <= l.xi && l.xi <= rectangle[2] && rectangle[1] <= l.yi && l.yi <= rectangle[3];
}

Location intersect(Location l1, Location l2, Location l3, Location l4) {
  // Line AB represented as a1x + b1y = c1
  double a1 = l2.y - l1.y;
  double b1 = l1.x - l2.x;
  double c1 = a1 * (l1.x) + b1 * (l1.y);

  // Line CD represented as a2x + b2y = c2
  double a2 = l4.y - l3.y;
  double b2 = l3.x - l4.x;
  double c2 = a2 * (l3.x) + b2 * (l3.y);

  double determinant = a1 * b2 - a2 * b1;

  if (determinant == 0) {
    // The lines are parallel. This is simplified
    // by returning a pair of FLT_MAX
    return null;
  } else {
    double x = (b2 * c1 - b1 * c2) / determinant;
    double y = (a1 * c2 - a2 * c1) / determinant;
    return new Location(x, y);
  }
}

Future getImage(String fileName) async {
  var f = File('assets/images/$fileName.jpg');
  final bytes = await f.readAsBytes();
  return decodeImage(bytes);
}

List<Location> getLineCoordinates(ThetaRho e, int xOffset, int yOffset, List<int> rectangle) {
  if (cos(e.theta) != 0 && sin(e.theta) != 0) {
    var x1 = 0;
    var y1 = (-cos(e.theta) / sin(e.theta)) * x1 + (e.rho / sin(e.theta));
    var x2 = x1 + 1000;
    var y2 = (-cos(e.theta) / sin(e.theta)) * x2 + (e.rho / sin(e.theta));

    List<int> line = [x1.toInt(), y1.toInt(), x2.toInt(), y2.toInt()];
    clipLine(line, rectangle);

    return [Location((line[0] + xOffset).toDouble(), (line[1] + yOffset).toDouble()), Location((line[2] + xOffset).toDouble(), (line[3] + yOffset).toDouble())];
  }
  return null;
}

void log(ThetaRho e) {
  print("${e.theta / (pi / 180)} ${e.theta} - ${e.rho}");
}

List<List<int>> calculateBWMatrix(Image image, int colorCount) {
  var retVar = createMatrix<int>(image.width, image.height, () => 0);

  for (var x = 0; x < image.width; x++) {
    for (var y = 0; y < image.height; y++) {
      int c = image.getPixel(x, y);
      var l = (getRed(c) + getBlue(c) + getGreen(c)) ~/ 3 ~/ (256 ~/ colorCount) * (256 ~/ colorCount);
      retVar[x][y] = l;
    }
  }
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

List<List<T>> createMatrix<T>(int n, int m, T defaultValue()) {
  return _generateList<List<T>>(n, () => _generateList<T>(m, () => defaultValue()));
}

List<T> _generateList<T>(int length, T defaultValue()) {
  return List<T>.generate(length, (index) => defaultValue(), growable: false);
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
