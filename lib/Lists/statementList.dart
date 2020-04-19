import 'dart:io';

import 'package:covid19_4ro/Forms/addressForm.dart';
import 'package:covid19_4ro/Forms/statementOnYourLiabilityForm.dart';
import 'package:covid19_4ro/Lists/personList.dart';

import 'package:covid19_4ro/Model/statementOnYourLiability.dart';
import 'package:covid19_4ro/Repository/addressRepository.dart';
import 'package:covid19_4ro/Repository/personRepository.dart';
import 'package:covid19_4ro/Repository/statementOnYourLiabilityRepository.dart';
import 'package:covid19_4ro/statementGenerator.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import '../localizations.dart';

class StatementListWidget extends StatefulWidget {
  @override
  StatementListState createState() => new StatementListState();
}

class StatementListState extends State<StatementListWidget> {
  final List<StatementOnYourLiability> _statements = <StatementOnYourLiability>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);

  @override
  void initState() {
    _loadState().then((value) {
      _statements.addAll(value);
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToStatementCreator,
        child: Icon(Icons.plus_one),
        backgroundColor: Colors.green,
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _statements.length == 0 ? 0 : _statements.length * 2 - 1,
      itemBuilder: (BuildContext _context, int i) {
        // Add a one-pixel-high divider widget before each row
        // in the ListView.
        if (i.isOdd) {
          return Divider();
        }

        final int index = i ~/ 2;
        return _buildRow(_statements[index], index);
      },
    );
  }

  Widget _buildRow(StatementOnYourLiability statementOnYourLiability, int index) {
    return Dismissible(
        key: Key(statementOnYourLiability.key),
        onDismissed: (direction) {
          setState(() {
            _statements.removeAt(index);
            _saveState(_statements);
          });

          var message = getLocalizedValue("StatementDeleted").replaceAll("#", statementOnYourLiability.destination);
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
        },
        child: ListTile(
          title: Text(
            statementOnYourLiability.destination,
            style: _biggerFont,
          ),
          trailing: IconButton(icon: Icon(Icons.edit), onPressed: () => _navigateToStatementEditor(statementOnYourLiability)),
          onTap: () {
            _navigateToStatementViewer(statementOnYourLiability.key);
          },
        ));
  }

  void saveStateAndUpdateView() {
    _saveState(_statements);
    setState(() {});
  }

  Future<void> _navigateToStatementViewer(String key) async {
    var personRepository = new PersonRepository();
    var persons = await personRepository.readData();

    if (persons.length > 0) persons = persons.where((p) => p.templateName != null && p.templateName.isNotEmpty).toList();

    if (persons.length == 0) {
      await _showAlert(getLocalizedValue('oops'), getLocalizedValue('PersonsMissing'));
      _navigateToPersonList();
      return;
    }

    var addressRepository = new AddressRepository();
    var address = await addressRepository.readData();

    if (address == null || (address.addressLine1.isEmpty && address.addressLine2.isEmpty)) {
      await _showAlert(getLocalizedValue('oops'), getLocalizedValue('AddressMissing'));
      _navigateToAddressEditor();
      return;
    }

    var statement = _statements.firstWhere((element) => element.key == key);

    StatementGenerator sg = StatementGenerator(context, statement);
    sg.generateStatements(persons, address, _saveImageToGalery);
  }

  Future<void> _saveImageToGalery(List<int> data) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg';
    await File(filePath).writeAsBytes(data);
    await GallerySaver.saveImage(filePath);
  }

  void _navigateToStatementCreator() {
    StatementOnYourLiability statement = StatementOnYourLiability.createNewStatementOnYourLiability();

    _navigateToScaffold(StatementOnYourLiabilityWidget(statement), getLocalizedValue("NewStatement")).then((value) {
      if (value != null && value is StatementOnYourLiability) {
        _statements.add(value);
        saveStateAndUpdateView();
      }
    });
  }

  dynamic _navigateToStatementEditor(StatementOnYourLiability statement) async {
    _navigateToScaffold(StatementOnYourLiabilityWidget(statement), getLocalizedValue("StatementDetails")).then((value) {
      if (value != null && value is StatementOnYourLiability) {
        statement.setFields(value);

        saveStateAndUpdateView();
      }
    });
  }

  Future<List<StatementOnYourLiability>> _loadState() async {
    StatementOnYourLiabilityRepository repo = new StatementOnYourLiabilityRepository();
    var data = await repo.readData();

    if (data.length == 0) {
      StatementOnYourLiability statement = StatementOnYourLiability(UniqueKey().toString(), getLocalizedValue('DemoDestination'), [2], "");
      data.add(statement);
    }

    return data;
  }

  void _saveState(List<StatementOnYourLiability> statements) {
    StatementOnYourLiabilityRepository repo = new StatementOnYourLiabilityRepository();
    repo.writeData(statements);
  }

  void _navigateToAddressEditor() {
    _navigateToScaffold(AddressWidget(), getLocalizedValue('AddressWidgetTitle'));
  }

  void _navigateToPersonList() {
    _navigateTo(PersonListWidget());
  }

  dynamic _navigateTo(StatefulWidget widget) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) {
        return Center(child: widget);
      }),
    );
    return result;
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
              ));
        },
      ),
    );
    return result;
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

  String getLocalizedValue(String key) => AppLocalizations.of(context).translate(key);
  Text getLocalizedText(String key) => Text(getLocalizedValue(key));
}
