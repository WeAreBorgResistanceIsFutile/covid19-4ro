import 'dart:convert';

class JsonHelper {
  static String complexObjectListToJson<T>(List<T> list, Function convertItemToJson) {
    String innerJson = list.map((e) => convertItemToJson(e)).toList().join(',');
    return '[' + innerJson + ']';
  }

  static List<T> jsonToComplexObjectList<T>(String json, Function createItem) {
    var list = jsonDecode(json);
    var retVar = List<T>.from(list.map((m)=>createItem(m)));
    return retVar;
  }

}