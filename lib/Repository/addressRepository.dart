
import 'package:covid19_4ro/Model/address.dart';
import 'package:covid19_4ro/Repository/repositoryBase.dart';

class AddressRepository extends RepositoryBase<Address> {
  AddressRepository() : super("addressDetails");

  @override
  Address createDefault() {
    return new Address('', '');
  }

  @override
  Address createFromJson(Map<String, dynamic> json) {
    return Address.fromJson(json);
  }
}
