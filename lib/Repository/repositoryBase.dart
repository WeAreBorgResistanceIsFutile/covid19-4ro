import 'dart:convert';
import 'dart:io';

import 'package:covid19_4ro/Model/modelBase.dart';
import 'package:path_provider/path_provider.dart';

abstract class RepositoryBase<T extends ModelBase> {
  String repoName;

  RepositoryBase(this.repoName);

  Future<Null> writeData(T data) async {
    final file = await _localFile;

    String serializedData = jsonEncode(data);
    file.writeAsString('$serializedData');
  }

  Future<T> readData() async {
    T retVar = createDefault();
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        Map<String, dynamic> decodedData = jsonDecode(contents);

        retVar = createFromJson(decodedData);
      }
    } catch (e) {}
    return retVar;
  }

  T createFromJson(Map<String, dynamic> json);
  T createDefault();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$repoName.txt');
  }
}
