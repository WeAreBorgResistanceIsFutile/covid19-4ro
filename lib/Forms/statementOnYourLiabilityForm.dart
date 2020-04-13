import 'package:covid19_4ro/Model/statementOnYourLiability.dart';
import 'package:covid19_4ro/Model/formHelper.dart';
import 'package:covid19_4ro/MultiSelect/multiselect_formfield.dart';
import 'package:flutter/material.dart';

import '../localizations.dart';

class StatementOnYourLiabilityWidget extends StatefulWidget {
  final StatementOnYourLiability _statement;
  StatementOnYourLiabilityWidget(this._statement, {Key key}) : super(key: key);

  @override
  StatementOnYourLiabilityWidgetState createState() => StatementOnYourLiabilityWidgetState(_statement);
}

class StatementOnYourLiabilityWidgetState extends State<StatementOnYourLiabilityWidget> {
  static const int AgriculturalActivityReason = 6;
  final _formKey = GlobalKey<FormState>();

  List<dynamic> _activities;

  final StatementOnYourLiability _statement;

  List<Map<dynamic, dynamic>> getReasons(BuildContext context) {
    return [
      (new KeyValuePair(1, getLocalizedValue("reason1"))).toMap(),
      (new KeyValuePair(2, getLocalizedValue("reason2"))).toMap(),
      (new KeyValuePair(3, getLocalizedValue("reason3"))).toMap(),
      (new KeyValuePair(4, getLocalizedValue("reason4"))).toMap(),
      (new KeyValuePair(5, getLocalizedValue("reason5"))).toMap(),
      (new KeyValuePair(6, getLocalizedValue("reason6"))).toMap(),
      (new KeyValuePair(7, getLocalizedValue("reason7"))).toMap(),
      (new KeyValuePair(8, getLocalizedValue("reason8"))).toMap(),
      (new KeyValuePair(9, getLocalizedValue("reason9"))).toMap(),
      (new KeyValuePair(10, getLocalizedValue("reason10"))).toMap()
    ];
  }

  final TextEditingController _destinationController = new TextEditingController();
  final TextEditingController _agriculturalActivitiyDescriptionController = new TextEditingController();

  StatementOnYourLiabilityWidgetState(this._statement) {
    if (_statement != null) {
      _destinationController.text = _statement.destination;
      _agriculturalActivitiyDescriptionController.text = _statement.agriculturalActivityDescription;
      _activities = _statement.reasonForTheMove.map((e) => e as dynamic).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildDestinationField(),
          buildReasonField(),
          buildAgriculturalActivitiyDescriptionField(),
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
            var activites = _activities.map((e) => e as int).toList();
            var statement = new StatementOnYourLiability(_statement.key, _destinationController.text, activites, _agriculturalActivitiyDescriptionController.text);
            _navigateBack(statement);
          }
        },
        child: getLocalizedText("Save"),
      ),
    );
  }

  Padding buildAgriculturalActivitiyDescriptionField() {
    final FormHelper fh = new FormHelper();
    if (_activities != null && _activities.length > 0 && _activities.contains(AgriculturalActivityReason))
      return fh.builTextField(_agriculturalActivitiyDescriptionController, getLocalizedValue("agriculturalActivityDescription"), getLocalizedValue("agriculturalActivityDescriptionValidation"), 10);
    else
      return fh.builTextField(_agriculturalActivitiyDescriptionController, getLocalizedValue("agriculturalActivityDescription"), null, 10);
  }

  Padding buildDestinationField() {
    final FormHelper fh = new FormHelper();
    return fh.builTextField(_destinationController, getLocalizedValue("destination"), getLocalizedValue("destinationValidation"), 10);
  }

  Padding buildReasonField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: MultiSelectFormField(
        autovalidate: false,
        titleText: getLocalizedValue('reason'),
        validator: (value) {
          if (value == null || value.length == 0) {
            return getLocalizedValue('reasonValidation');
          }
          return null;
        },
        dataSource: getReasons(context),
        textField: 'display',
        valueField: 'value',
        okButtonLabel: getLocalizedValue('OK'),
        cancelButtonLabel: getLocalizedValue('Cancel'),
        // required: true,
        hintText: getLocalizedValue('reasonHint'),
        value: _activities,
        initialValue: _activities.toList(),
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            _activities = value;
          });
        },
      ),
    );
  }

  void _navigateBack(StatementOnYourLiability statement) {
    Navigator.pop(context, statement);
  }

  String getLocalizedValue(String key) => AppLocalizations.of(context).translate(key);
  Text getLocalizedText(String key) => Text(getLocalizedValue(key));
}

class KeyValuePair {
  final int _value;
  final String _display;

  int value() => this._value;
  String display() => this._display;

  KeyValuePair(this._value, this._display);

  Map toMap() {
    Map map = new Map();
    map['value'] = this._value;
    map['display'] = this._display;
    return map;
  }
}
