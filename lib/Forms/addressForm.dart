import 'package:covid19_4ro/Model/address.dart';
import 'package:covid19_4ro/Model/formHelper.dart';
import 'package:covid19_4ro/Repository/addressRepository.dart';
import 'package:flutter/material.dart';

import '../localizations.dart';

class AddressWidget extends StatefulWidget {
  AddressWidget({Key key}) : super(key: key);

  @override
  AddressWidgetState createState() => AddressWidgetState();
}

class AddressWidgetState extends State<AddressWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressLine1Controller = new TextEditingController();
  final TextEditingController _addressLine2Controller = new TextEditingController();

  @override
  void initState() {
    _loadState().then((value) => _init(value));
    super.initState();
  }

  void _init(Address a) {
    _addressLine1Controller.text = a.addressLine1;
    _addressLine2Controller.text = a.addressLine2;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildAddressLine1(),
          buildAddressLine2(),
          buildSaveButton(),
        ],
      ),
    );
  }

  Padding buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _saveState(_addressLine1Controller.text, _addressLine2Controller.text);
            _navigateBack();
          }
        },
        child: getLocalizedText("Save"),
      ),
    );
  }

  Padding buildAddressLine1() {
    final FormHelper fh = new FormHelper();
    return fh.builTextField(_addressLine1Controller, getLocalizedValue("AddressLine1"), getLocalizedValue("AddressValidation"), 10);
  }

  Padding buildAddressLine2() {
    final FormHelper fh = new FormHelper();
    return fh.builTextField(_addressLine2Controller, getLocalizedValue("AddressLine2"), null, 10);
  }

  Future<Address> _loadState() async {
    AddressRepository repo = new AddressRepository();

    Address address = await repo.readData();
    return address;
  }

  void _saveState(String addressLine1, String addressLine2) {
    AddressRepository repo = new AddressRepository();

    Address address = new Address(addressLine1, addressLine2);
    repo.writeData(address);
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  String getLocalizedValue(String key) => AppLocalizations.of(context).translate(key);
  Text getLocalizedText(String key) => Text(getLocalizedValue(key));
}
