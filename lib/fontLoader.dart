import 'dart:typed_data';

import 'package:flutter/services.dart';

class CreateFontDart {
  static Future<String> create(String fontName, int size) async {
    ByteData imageData = await rootBundle.load('assets/fonts/verdana14.zip');
    List<int> bytes = Uint8List.view(imageData.buffer);
    var strByteArray = bytes.map((e) => e.toString()).toList().join(',');
    final String classCode = '''import \'package:image/image.dart\';

final BitmapFont ${fontName}_$size = BitmapFont.fromZip(_${fontName.toUpperCase()}_$size);

const List<int> _${fontName.toUpperCase()}_$size = [$strByteArray];''';
    return classCode;
  }
}
