import 'birthday.dart';
import 'modelBase.dart';

class Person extends ModelBase {
  String _firstName;
  String _lastName;
  Birthday _birthday;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get dayOfBirth => _birthday.day;
  String get monthOfBirth => _birthday.month;
  String get yearOfBirth => _birthday.year;

  String get name => "$firstName $lastName";

  Person(this._firstName, this._lastName, this._birthday) : super.fromJson(null);

  @override
  Person.fromJson(Map<String, dynamic> json)
      : _firstName = json['firstName'],
        _lastName = json['lastName'],
        _birthday = Birthday.fromJson(json['birthday']),
        super.fromJson(null);

  @override
  Map<String, dynamic> toJson() => {'firstName': _firstName, 'lastName': _lastName, 'birthday': _birthday};

  DateTime getBirthday() {
    return _birthday.getBirthday();
  }

  void setFields(Person person) {
    _firstName = person.firstName;
    _lastName = person.lastName;
    _birthday = person._birthday;
  }
}
