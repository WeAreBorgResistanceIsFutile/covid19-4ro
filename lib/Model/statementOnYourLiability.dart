import 'package:flutter/cupertino.dart';

import '../jsonHelper.dart';
import 'modelBase.dart';

class StatementOnYourLiability extends ModelBase {
  String _destination;
  List<int> _reasonForTheMove;
  String _agriculturalActivityDescription;
  String _key;

  String get key => _key;
  String get destination => _destination;
  List<int> get reasonForTheMove => _reasonForTheMove;

  String get agriculturalActivityDescription =>
      _agriculturalActivityDescription;

  StatementOnYourLiability(this._key, this._destination,
      this._reasonForTheMove, this._agriculturalActivityDescription)
      : super.fromJson(null);

  StatementOnYourLiability.fromJson(Map<String, dynamic> json)
      : _key = json['key'],
        _destination = json['destination'],
        _reasonForTheMove = JsonHelper.jsonToComplexObjectList<int>(json['reasonForTheMove'], (int str)=>str),
        _agriculturalActivityDescription =
            json['agriculturalActivityDescription'],
        super.fromJson(null);

  @override
  Map<String, dynamic> toJson() => {
        'key': _key,
        'destination': _destination,
        'reasonForTheMove': JsonHelper.complexObjectListToJson<int>(_reasonForTheMove, (int i)=> i.toString()),
        'agriculturalActivityDescription': _agriculturalActivityDescription
      };

  void setFields(StatementOnYourLiability statement)
  {
      _destination = statement.destination;
      _reasonForTheMove.clear();
      _reasonForTheMove.addAll(statement.reasonForTheMove);
      _agriculturalActivityDescription = statement.agriculturalActivityDescription;
  }

  

  static StatementOnYourLiability createNewStatementOnYourLiability() {
    return new StatementOnYourLiability(
        new UniqueKey().toString(), '', new List<int>(), '');
  }
}
