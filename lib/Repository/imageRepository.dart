import 'dart:io';

import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

class ImageRepository {
  String _repoName;

  ImageRepository(this._repoName);

  Future<Null> writeData(Image data) async {
    final file = await _localFile;

    file.writeAsBytes(data.getBytes());
  }

  Future<Image> readData() async {
    try {
      final file = await _localFile;
      return decodeImage(await file.readAsBytes());
    } catch (e) {
      return null;
    }
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
    return '$path/$_repoName.jpg';
  }
}
