import 'dart:convert';
import 'dart:io';

import 'package:covid19_4ro/Model/person.dart';
import 'package:path_provider/path_provider.dart';

class PersonRepository {
  static const String repoName = "personList";

  Future<Null> writeData(List<Person> data) async {
    final file = await _localFile;

    String serializedData = jsonEncode(data);
    file.writeAsString('$serializedData');
  }

  Future<List<Person>> readData() async {
    List<Person> retVar = List<Person>();
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        var decodedData = jsonDecode(contents);

        retVar = createFromJson(decodedData);
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
    return File('$path/$repoName.txt');
  }

  List<Person> createFromJson(List<dynamic> decodedData) {
    return decodedData.map((e) => Person.fromJson(e)).toList();
  }
}
