import 'modelBase.dart';

class Birthday extends ModelBase {
  DateTime _birthday;

  String get day => _birthday.day.toString().padLeft(2, "0");
  String get month => _birthday.month.toString().padLeft(2, "0");
  String get year => _birthday.year.toString().padLeft(4, "0");

  Birthday(this._birthday) : super.fromJson(null);

  Birthday.fromJson(Map<String, dynamic> json) : _birthday = DateTime.parse(json['birthday']), super.fromJson(null);

  @override
  Map<String, dynamic> toJson() => {'birthday': _birthday.toIso8601String()};

  DateTime getBirthday(){
    return _birthday;
  }
}
