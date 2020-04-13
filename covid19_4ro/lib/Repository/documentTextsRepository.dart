import 'dart:convert';
import 'dart:io';

import 'package:covid19_4ro/Model/documentElement.dart';
import 'package:covid19_4ro/Model/documentText.dart';
import 'package:path_provider/path_provider.dart';

class DocumentTextsRepository {
  static const String repoName = "documentText";

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
    try {
      final file = await _localFile;

      String contents = await file.readAsString();
      Map<String, dynamic> decodedData = jsonDecode(contents);
      Map<String, DocumentText> retVar = {};
      decodedData.forEach((key, value) {
        retVar[key] = DocumentText.fromJson(value);
      });
      return retVar;
    } catch (e) {
      return new Map<String, DocumentElement>();
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$repoName.txt');
  }
}
