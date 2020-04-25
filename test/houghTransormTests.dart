import 'dart:io';

import 'package:covid19_4ro/houghTransform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';

void main() {
  group("Hough transform tests", () {
    test("HoughTransform.getAllLines", () async {
      Image img = await getImage('test_image');

      DateTime t = DateTime.now();
      HoughTransform ht = HoughTransform(img);

      var a = ht.getAllLines();

      print("HoughTransform.getAllLines:  ${DateTime.now().difference(t).inMicroseconds}");

      expect(a.length, equals(21));
      expect(a[0].rho, -477);
      expect(a[0].theta, -3.141592653589793);
      expect(a[1].rho, -166);
      expect(a[1].theta, -3.132866007329822);
      expect(a[2].rho, -686);
      expect(a[2].theta, -1.5882496193149365);
      expect(a[3].rho, -852);
      expect(a[3].theta, -1.5707963267949943);
      expect(a[4].rho, 0);
      expect(a[4].theta, -1.5707963267949943);
      expect(a[5].rho, -232);
      expect(a[5].theta, -1.5673056682910058);
      expect(a[6].rho, -605);
      expect(a[6].theta, -1.5655603390390116);
      expect(a[7].rho, -756);
      expect(a[7].theta, -1.5358897417551098);
      expect(a[8].rho, 476);
      expect(a[8].theta, -1.318342136846784e-13);
      expect(a[9].rho, 166);
      expect(a[9].theta, 0.008726646259839814);
      expect(a[10].rho, 686);
      expect(a[10].theta, 1.5533430342747883);
      expect(a[11].rho, 0);
      expect(a[11].theta, 1.5707963267947305);
      expect(a[12].rho, 852);
      expect(a[12].theta, 1.5707963267947305);
      expect(a[13].rho, 232);
      expect(a[13].theta, 1.574286985298719);
      expect(a[14].rho, 605);
      expect(a[14].theta, 1.5760323145507131);
      expect(a[15].rho, 756);
      expect(a[15].theta, 1.6057029118346149);
      expect(a[16].rho, -425);
      expect(a[16].theta, 3.138101995085541);
      expect(a[17].rho, -216);
      expect(a[17].theta, 3.139847324337535);
      expect(a[18].rho, -638);
      expect(a[18].theta, 3.1415926535895293);
      expect(a[19].rho, -476);
      expect(a[19].theta, 3.1415926535895293);
      expect(a[20].rho, -162);
      expect(a[20].theta, 3.1415926535895293);      
    });
    test("HoughTransform.getPageBoundaryLines", () async {
      Image img = await getImage('test_image');

      DateTime t = DateTime.now();
      HoughTransform ht = HoughTransform(img);

      var a = ht.getPageBoundaryLines();

      print("HoughTransform.getPageBoundaryLines:  ${DateTime.now().difference(t).inMicroseconds}");

      expect(a.length, equals(4));
      expect(a[0].rho, equals(709));
      expect(a[0].theta, 0.008726646259839814);
      expect(a[1].rho, 2034);
      expect(a[1].theta, -1.318342136846784e-13);
      expect(a[2].rho, 991);
      expect(a[2].theta, 1.574286985298719);
      expect(a[3].rho, 3231);
      expect(a[3].theta, 1.6057029118346149);
      
    });
    test("HoughTransform.getAllLines  less theta subunits", () async {
      Image img = await getImage('test_image');

      DateTime t = DateTime.now();
      HoughTransform ht = HoughTransform(img, thetaSubunitsPerDegree: 1);

      var a = ht.getAllLines();

      print("HoughTransform.getAllLines  less theta subunits:  ${DateTime.now().difference(t).inMicroseconds}");

      expect(a.length, equals(23));
      expect(a[0].rho, -477);
      expect(a[0].theta, -3.141592653589793);
      expect(a[1].rho, -163);
      expect(a[1].theta, -3.141592653589793);
      expect(a[2].rho, -686);
      expect(a[2].theta, -1.588249619314852);
      expect(a[3].rho, -852);
      expect(a[3].theta, -1.5707963267949088);
      expect(a[4].rho, -607);
      expect(a[4].theta, -1.5707963267949088);
      expect(a[5].rho, -406);
      expect(a[5].theta, -1.5707963267949088);
      expect(a[6].rho, -234);
      expect(a[6].theta, -1.5707963267949088);
      expect(a[7].rho, 0);
      expect(a[7].theta, -1.5707963267949088);
      expect(a[8].rho, -756);
      expect(a[8].theta, -1.5358897417550221);
      expect(a[9].rho, -286);
      expect(a[9].theta, -1.5358897417550221);
      expect(a[10].rho, 162);
      expect(a[10].theta, -1.0401401961956935e-14);
      expect(a[11].rho, 476);
      expect(a[11].theta, -1.0401401961956935e-14);
      expect(a[12].rho, 686);
      expect(a[12].theta, 1.5533430342749446);
      expect(a[13].rho, 0);
      expect(a[13].theta, 1.570796326794888);
      expect(a[14].rho, 234);
      expect(a[14].theta, 1.570796326794888);
      expect(a[15].rho, 406);
      expect(a[15].theta, 1.570796326794888);
      expect(a[16].rho, 557);
      expect(a[16].theta, 1.570796326794888);
      expect(a[17].rho, 607);
      expect(a[17].theta, 1.570796326794888);
      expect(a[18].rho, 852);
      expect(a[18].theta, 1.570796326794888);
      expect(a[19].rho, 286);
      expect(a[19].theta, 1.6057029118347745);
      expect(a[20].rho, 756);
      expect(a[20].theta, 1.6057029118347745);
      expect(a[21].rho, -476);
      expect(a[21].theta, 3.1415926535897722);
      expect(a[22].rho, -162);
      expect(a[22].theta, 3.1415926535897722);
      
    });
    test("HoughTransform.getPageBoundaryLines less theta subunits", () async {
      Image img = await getImage('test_image');

      DateTime t = DateTime.now();
      HoughTransform ht = HoughTransform(img, thetaSubunitsPerDegree: 1);

      var a = ht.getPageBoundaryLines();

      print("HoughTransform.getPageBoundaryLines less theta subunits:  ${DateTime.now().difference(t).inMicroseconds}");

      expect(a.length, equals(4));
      expect(a[0].rho, 692);
      expect(a[0].theta, -1.0401401961956935e-14);
      expect(a[1].rho, 2034);
      expect(a[1].theta, -1.0401401961956935e-14);
      expect(a[2].rho, 1000);
      expect(a[2].theta, 1.570796326794888);
      expect(a[3].rho, 3231);
      expect(a[3].theta, 1.6057029118347745);      
    });
  

    // var xStart = xCenter - range > 0 ? xCenter - range : 0;
    // var yStart = yCenter - range > 0 ? yCenter - range : 0;
    // var xEnd = xCenter + range <= matrix.length ? xCenter + range : matrix.length;
    // var yEnd = yCenter + range <= matrix[0].length ? yCenter + range : matrix[0].length;


    test("HoughTransform.getPageBoundaryLines", () async {
      Image img = await getImage('test_image');

      DateTime t = DateTime.now();
      HoughTransform ht = HoughTransform(img, thetaSubunitsPerDegree: 1);

      var a = ht.getPageBoundaryLines();

      print("HoughTransform.getPageBoundaryLines:  ${DateTime.now().difference(t).inMicroseconds}");

      expect(a.length, equals(4));
      expect(a[0].rho, 692);
      expect(a[0].theta, -1.0401401961956935e-14);
      expect(a[1].rho, 2034);
      expect(a[1].theta, -1.0401401961956935e-14);
      expect(a[2].rho, 1000);
      expect(a[2].theta, 1.570796326794888);
      expect(a[3].rho, 3231);
      expect(a[3].theta, 1.6057029118347745);      
    });
  });
}

Future getImage(String fileName) async {
  var f = File('assets/images/$fileName.jpg');
  final bytes = await f.readAsBytes();
  return decodeImage(bytes);
}
