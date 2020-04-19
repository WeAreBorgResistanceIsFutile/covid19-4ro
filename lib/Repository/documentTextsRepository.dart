import 'dart:convert';
import 'dart:io';

import 'package:covid19_4ro/Model/documentText.dart';
import 'package:path_provider/path_provider.dart';

class DocumentTextsRepository {
  final String repoName;

  DocumentTextsRepository(this.repoName);

  Future<Null> deleteRepository() async {
    final file = await _localFile;

    if (await file.exists()) file.delete();
  }

  Future<Null> writeData(Map<String, DocumentText> data) async {
    final file = await _localFile;

    List<String> list = new List<String>();
    data.forEach((key, value) {
      list.add('"$key" : ${jsonEncode(value)}');
    });

    String serializedData = "{ ${list.join(',')}}";
    file.writeAsString('$serializedData');
  }

  Future<Map<String, DocumentText>> readData() async {
    Map<String, DocumentText> retVar = {};
    try {
      final file = await _localFile;

      if (await file.exists()) {
        String contents = await file.readAsString();
        Map<String, dynamic> decodedData = jsonDecode(contents);

        decodedData.forEach((key, value) {
          retVar[key] = DocumentText.fromJson(value);
        });
      }
    } catch (e) {}
    return retVar;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$repoName.json');
  }
}
