import 'package:covid19_4ro/Model/birthday.dart';
import 'package:covid19_4ro/Model/documentTemplate.dart';
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
  DocumentTemplate _statementTemplate;

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
    if (p.templateName != null && p.templateName.isNotEmpty) {
      _statementTemplate = DocumentTemplate();
      _statementTemplate.loadTemplate(p.templateName).then((value) => setState);
    }
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
          buildImageField(),
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
            IconButton(icon: Icon(Icons.edit), onPressed: () => _selectDate(context)),
          ],
        ));
  }

  Padding buildImageField() {
    var message = _statementTemplate == null ? getLocalizedValue("StatementTemplateNotSet") : getLocalizedValue("StatementTemplateSet");

    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Text(message),
            IconButton(icon: _statementTemplate == null ? Icon(Icons.camera_alt) : Icon(Icons.image), onPressed: _navigateToImageTemplateViewer),
          ],
        ));
  }

  Padding buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: RaisedButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            if (_statementTemplate == null) {
              await _showAlert(getLocalizedValue('oops'), getLocalizedValue('StatementTemplateMissingWarning'));
            }

            var p = _createPerson(_firstNameController.text, _lastNameController.text, selectedDate, _statementTemplate);
            _navigateBack(p);
          }
        },
        child: getLocalizedText('Save'),
      ),
    );
  }

  Future<void> _navigateToImageTemplateViewer() async {
    var statementTemplate = await _navigateTo(StatementTemplateWidget(_statementTemplate));
    if (statementTemplate != null) {
      setState(() {
        _statementTemplate = statementTemplate;
      });
    }
  }

  Person _createPerson(String firstName, String lastName, DateTime birthday, DocumentTemplate statementTemplate) {
    return new Person.withStatementTemplate(firstName, lastName, new Birthday(birthday), statementTemplate);
  }

  Future<void> _showAlert(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: getLocalizedText('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  dynamic _navigateTo(StatefulWidget widget) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return widget;
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
