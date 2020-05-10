import 'dart:io';
import 'dart:math';

import 'package:covid19_4ro/Model/location.dart';
import 'package:covid19_4ro/houghTransform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';

void main() {
  group("Hough transform tests", () {
    test("HoughTransform.getAllLines", () async {
      var oneDegree = pi / 180 * 3;

      DateTime t = DateTime.now();
      for (var index = 1; index <= 44; index++) {
        var fileName = 'test_image$index';
        Image img = await getImage(fileName);

        HoughTransform ht = HoughTransform(img, thetaSubunitsPerDegree: 1);

        var lines = ht.getAllLines();

        //lines = lines.where((e) => e.rho != 0).toList();
        lines.sort((l1, l2) => l1.theta.compareTo(l2.theta));

        double thetaDelta = oneDegree * 5;
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
        print("$fileName - ${verticalLines.length}");

        
        //verticalLines.forEach((element) => log(element));
        var locations = verticalLines.map((e) => getLineCoordinates(e, 0, 0, [0, 0, img.width, img.height])).toList();

        img = copyResize(img, width: 160);

        for (var i = 0; i < locations.length; i++) {
          var e = locations[i];
          drawLine(img, e[0].xi, e[0].yi, e[1].xi, e[1].yi, getColor(250, 255, 0));
        }

        var f = File("alma$index.jpg");
        await f.writeAsBytes(encodeJpg(img));

        // print(locations.length);
      }

      // var lines = ht.getPageBoundaryLines();

      // var locations = lines.map((e) => getLineCoordinates(e, 0, 0, [0, 0, img.width, img.height])).toList();
      // if (locations.length == 4) {
      //   final vline1 = locations[0];
      //   final vline2 = locations[1];
      //   final hline1 = locations[2];
      //   final hline2 = locations[3];

      //   final Location pageTopLeftLocation = Location(vline1[0].x, hline1[0].y);
      //   final Location pageTopRightLocation = Location(vline2[0].x, hline1[1].y);
      //   final Location pageBottomLeftLocation = Location(vline1[1].x, hline2[0].y);
      //   final Location pageBottomRightLocation = Location(vline2[1].x, hline2[1].y);

      //   drawCircle(img, pageTopLeftLocation.x.toInt(), pageTopLeftLocation.y.toInt(), 10, getColor(250, 0, 0));
      //   drawCircle(img, pageTopRightLocation.x.toInt(), pageTopRightLocation.y.toInt(), 10, getColor(250, 255, 0));
      //   drawCircle(img, pageBottomLeftLocation.x.toInt(), pageBottomLeftLocation.y.toInt(), 10, getColor(250, 255, 255));
      //   drawCircle(img, pageBottomRightLocation.x.toInt(), pageBottomRightLocation.y.toInt(), 10, getColor(0, 0, 0));
      // }

      print("HoughTransform.getAllLines:  ${DateTime.now().difference(t).inMicroseconds}");

      //expect(a.length, equals(21));
    });

    test("HoughTransform.getAllLines asdfasdf", () async {
      var img = Image(1000, 1000);
      img.fill(getColor(255, 255, 255));

      // ThetaRho tr = ThetaRho(pi/4, 50);

      // ThetaRho tr = ThetaRho(pi/4 - pi, -50);
      // ThetaRho tr = ThetaRho(pi/4 - 2 * pi, 50);
      // ThetaRho tr = ThetaRho(-180 * (pi / 180), -119);

      ThetaRho tr = ThetaRho(0 * (pi / 180), -100);
      var location = getLineCoordinates(tr, 0, 0, [0, 0, img.width, img.height]);
      drawLine(img, location[0].xi, location[0].yi, location[1].xi, location[1].yi, getColor(250, 255, 0));
      var f = File("line.jpg");
      await f.writeAsBytes(encodeJpg(img));
    });

    test("thetaRhoAlmostEqual", () async {
      ThetaRho e1 = ThetaRho(pi / 4, 50);
      ThetaRho e2 = ThetaRho(pi / 4 - 3 * pi, -50);
      expect(thetaRhoAlmostEqual(e1, e2, 1, 0.1), true);
    });

    test("thetaRhoAlmostEqual", () async {
      ThetaRho e1 = ThetaRho(pi / 4 - pi, -50);
      ThetaRho e2 = ThetaRho(pi / 4, 50);
      expect(thetaRhoAlmostEqual(e1, e2, 1, 0.1), true);
    });

    test("thetaRhoAlmostEqual", () async {
      ThetaRho e1 = ThetaRho(pi / 4 - 2 * pi, 50);
      ThetaRho e2 = ThetaRho(pi / 4, 50);
      expect(thetaRhoAlmostEqual(e1, e2, 1, 0.1), true);
    });

    test("thetaRhoAlmostEqual", () async {
      ThetaRho e1 = ThetaRho(pi / 4 + pi / 180, 50);
      ThetaRho e2 = ThetaRho(pi / 4, 50);
      expect(thetaRhoAlmostEqual(e1, e2, 1, pi / 180 * 3), true);
    });

    test("thetaRhoAlmostEqual", () async {
      ThetaRho e1 = ThetaRho(-pi, 50);
      ThetaRho e2 = ThetaRho(0, -50);
      expect(thetaRhoAlmostEqual(e1, e2, 1, pi / 180 * 3), true);
    });

    test("thetaRhoAlmostEqual 2", () async {
      ThetaRho e1 = ThetaRho(0, -100);
      ThetaRho e2 = ThetaRho(pi, -100);
      expect(thetaRhoAlmostEqual(e1, e2, 10, (pi / 180) * 3), true);
    });


    test("thetaRhoAlmostEqual 2", () async {
      ThetaRho e1 = ThetaRho(0, -100);
      ThetaRho e2 = ThetaRho(pi, 120);
      expect(thetaRhoAlmostEqual(e1, e2, 10, (pi / 180) * 3), false);
    });
  });
}

bool hasMatch(List<ThetaRho> lines, ThetaRho e1, int rhoDelta, double thetaDelta) {
  bool retVar = false;
  lines.forEach((e) => retVar = retVar || thetaRhoAlmostEqual(e, e1, rhoDelta, thetaDelta));
  return retVar;
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

Future getImage(String fileName) async {
  var f = File('assets/images/$fileName.jpg');
  final bytes = await f.readAsBytes();
  return decodeImage(bytes);
}

List<Location> getLineCoordinates(ThetaRho e, int xOffset, int yOffset, List<int> rectangle) {
  double x1, y1, x2, y2;
  List<int> line;
  if (sin(e.theta) != 0) {
    x1 = 0;
    y1 = (-cos(e.theta) / sin(e.theta)) * x1 + (e.rho / sin(e.theta));
    x2 = x1 + 1000;
    y2 = (-cos(e.theta) / sin(e.theta)) * x2 + (e.rho / sin(e.theta));
    line = [x1.toInt(), y1.toInt(), x2.toInt(), y2.toInt()];
    clipLine(line, rectangle);
  } else {
    x1 = 0;
    y1 = 0;
    x2 = 0;
    y2 = 10000;
    line = [0, 0, 0, rectangle[3]];
  }

  return [Location((line[0] + xOffset).toDouble(), (line[1] + yOffset).toDouble()), Location((line[2] + xOffset).toDouble(), (line[3] + yOffset).toDouble())];
}

void log(ThetaRho e) {
  print("${e.theta / (pi / 180)} ${e.theta} - ${e.rho}");
}
