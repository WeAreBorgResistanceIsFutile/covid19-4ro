import 'package:covid19_4ro/Model/birthday.dart';
import 'package:covid19_4ro/Model/formHelper.dart';
import 'package:covid19_4ro/Model/person.dart';
import 'package:flutter/material.dart';

import '../localizations.dart';
import '../statementTemplateWidget.dart';

class PersonWidget extends StatefulWidget {
  final Person person;

  PersonWidget(this.person, {Key key}) : super(key: key);

  @override
  PersonWidgetState createState() => PersonWidgetState();
}

class PersonWidgetState extends State<PersonWidget> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  String templatePath;

  final TextEditingController _firstNameController = new TextEditingController();
  final TextEditingController _lastNameController = new TextEditingController();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(1900), lastDate: DateTime.now().add(new Duration(days: 1)));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  void initState() {
    _init(widget.person);
    super.initState();
  }

  void _init(Person p) {
    selectedDate = p.getBirthday();
    _firstNameController.text = p.firstName;
    _lastNameController.text = p.lastName;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildLastNameField(),
          buildFirstNameField(),
          buildBirthdayField(context),
          buildSaveButton(),
        ],
      ),
    );
  }

  Padding buildLastNameField() {
    final FormHelper fh = new FormHelper();
    return fh.builTextField(_lastNameController, getLocalizedValue('lastName'), getLocalizedValue('firstNameValidation'), 10);
  }

  Padding buildFirstNameField() {
    final FormHelper fh = new FormHelper();
    return fh.builTextField(_firstNameController, getLocalizedValue('firstName'), getLocalizedValue('firstNameValidation'), 10);
  }

  Padding buildBirthdayField(BuildContext context) {
    var message = getLocalizedValue("Birthdate").replaceAll("#", selectedDate.toLocal().toString().split(' ')[0]);

    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Text(message),
            IconButton(icon: Icon(Icons.edit), onPressed: _navigateToImageTemplateViewer),
          ],
        ));
  }

  Padding buildImageField(BuildContext context) {
    var message = templatePath == null ? getLocalizedValue("StatementTemplateNotSet") : getLocalizedValue("StatementTemplateSet");

    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Text(message),
            IconButton(icon: templatePath == null ? Icon(Icons.camera_alt) : Icon(Icons.image), onPressed: () => _selectDate(context)),
          ],
        ));
  }

  Padding buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            var p = _createPerson(_firstNameController.text, _lastNameController.text, selectedDate);
            _navigateBack(p);
          }
        },
        child: getLocalizedText('Save'),
      ),
    );
  }

  Future<void> _navigateToImageTemplateViewer() async {
    var path = await _navigateToScaffold(StatementTemplateWidget(templatePath), getLocalizedValue('StatementTemplateWidgetTitle'));
    if (path != null) templatePath = path;
  }

  Person _createPerson(String firstName, String lastName, DateTime birthday) {
    return new Person(firstName, lastName, new Birthday(birthday));
  }

  dynamic _navigateToScaffold(StatefulWidget widget, String title) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: Center(
              child: widget,
            ),
          );
        },
      ),
    );
    return result;
  }

  void _navigateBack(Person person) {
    Navigator.pop(context, person);
  }

  String getLocalizedValue(String key) => AppLocalizations.of(context).translate(key);
  Text getLocalizedText(String key) => Text(getLocalizedValue(key));
}
