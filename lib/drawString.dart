import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';

var _r_lut = Uint8List(256);
var _g_lut = Uint8List(256);
var _b_lut = Uint8List(256);
var _a_lut = Uint8List(256);

Image drawString(Image image, BitmapFont font, int originX, int originY, String string, double theta, {int color = 0xffffffff}) {
  if (color != 0xffffffff) {
    var ca = getAlpha(color);
    if (ca == 0) {
      return image;
    }
    num da = ca / 255.0;
    num dr = getRed(color) / 255.0;
    num dg = getGreen(color) / 255.0;
    num db = getBlue(color) / 255.0;
    for (var i = 1; i < 256; ++i) {
      _r_lut[i] = (dr * i).toInt();
      _g_lut[i] = (dg * i).toInt();
      _b_lut[i] = (db * i).toInt();
      _a_lut[i] = (da * i).toInt();
    }
  }

  var x = originX;
  var y = originY;
  theta -= (pi / 2).toDouble();

  var chars = string.codeUnits;
  for (var c in chars) {
    if (!font.characters.containsKey(c)) {
      originX += font.base ~/ 2;
      continue;
    }

    var ch = font.characters[c];

    var x2 = x + ch.width;
    var y2 = y + ch.height;
    var pi = 0;
    for (var yi = y; yi < y2; ++yi) {
      for (var xi = x; xi < x2; ++xi) {
        var p = ch.image[pi++];
        if (color != 0xffffffff) {
          p = getColor(_r_lut[getRed(p)], _g_lut[getGreen(p)], _b_lut[getBlue(p)], _a_lut[getAlpha(p)]);
        }

        var xt = originX + rotateX(xi + ch.xoffset - originX, yi + ch.yoffset - originY, theta);
        var yt = originY + rotateY(xi + ch.xoffset - originX, yi + ch.yoffset - originY, theta);

        drawPixel(image, xt.toInt(), yt.toInt(), p);        
      }
    }

    x += ch.xadvance;
  }

  return image;
}

//https://en.wikipedia.org/wiki/Rotation_of_axes
double rotateY(int x, int y, double theta) => -x * sin(theta) + y * cos(theta);
double rotateX(int x, int y, double theta) => x * cos(theta) + y * sin(theta);
