import 'dart:io';

import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

class TemplateImageRepository {
  String _repoName = "template";

  TemplateImageRepository();

  Future<Null> writeData(Image data) async {
    final file = await _localFile;
    file.writeAsBytesSync(encodeJpg(data));
  }

  Future<Image> readData() async {
    Image retVar;
    try {
      final file = await _localFile;

      if (await file.exists()) {
        final bytes = file.readAsBytesSync();

        retVar = decodeImage(bytes);
      }
    } catch (e) {}
    return retVar;
  }

  Future<String> getFilePath() async {
    return _localFilePath;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    return File(await _localFilePath);
  }

  Future<String> get _localFilePath async {
    final path = await _localPath;
    return '$path/$_repoName.txt';
  }
}
