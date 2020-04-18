import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';

var _r_lut = Uint8List(256);
var _g_lut = Uint8List(256);
var _b_lut = Uint8List(256);
var _a_lut = Uint8List(256);

Image drawString(Image image, BitmapFont font, int x, int y, String string, double theta, {int color = 0xffffffff}) {
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

  var chars = string.codeUnits;
  for (var c in chars) {
    if (!font.characters.containsKey(c)) {
      x += font.base ~/ 2;
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

        //https://en.wikipedia.org/wiki/Rotation_of_axes
        var xt = (rotateX(xi, ch, theta, yi)).toInt();
        var yt = (rotateY(xi, ch, theta, yi)).toInt();

        drawPixel(image, xt, yt, p);
      }
    }

    x += ch.xadvance;
  }

  return image;
}

double rotateY(int xi, BitmapFontCharacter ch, double theta, int yi) => -(xi + ch.xoffset) * sin(theta) + (yi + ch.yoffset) * cos(theta);
double rotateX(int xi, BitmapFontCharacter ch, double theta, int yi) => (xi + ch.xoffset) * cos(theta) + (yi + ch.yoffset) * sin(theta);
