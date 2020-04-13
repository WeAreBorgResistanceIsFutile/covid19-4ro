import 'modelBase.dart';

class Address extends ModelBase {
  final String _addressLine1;
  final String _addressLine2;

  String get addressLine1 => _addressLine1;
  String get addressLine2 => _addressLine2;

  Address(this._addressLine1, this._addressLine2) : super.fromJson(null);

  Address.fromJson(Map<String, dynamic> json) : _addressLine1 = json['addressLine1'],  _addressLine2 = json['addressLine2'], super.fromJson(null);
  
  @override
  Map<String, dynamic> toJson() => {'addressLine1': _addressLine1, 'addressLine2': _addressLine2};
}