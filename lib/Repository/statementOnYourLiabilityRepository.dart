import 'dart:convert';
import 'dart:io';

import 'package:covid19_4ro/Model/statementOnYourLiability.dart';
import 'package:path_provider/path_provider.dart';

class StatementOnYourLiabilityRepository {
  static const String repoName = "statementOnYourLiabilityDetails";

  Future<Null> writeData(List<StatementOnYourLiability> data) async {
    final file = await _localFile;

    String serializedData = jsonEncode(data);
    file.writeAsString('$serializedData');
  }

  Future<List<StatementOnYourLiability>> readData() async {
    List<StatementOnYourLiability> retVar = List<StatementOnYourLiability>();
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        var decodedData = jsonDecode(contents);

        retVar = createFromJson(decodedData);
      }
    } catch (e) {
      return new List<StatementOnYourLiability>();
    }
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

  List<StatementOnYourLiability> createFromJson(List<dynamic> decodedData) {
    return decodedData.map((e) => StatementOnYourLiability.fromJson(e)).toList();
  }
}
