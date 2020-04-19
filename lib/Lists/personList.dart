import 'package:covid19_4ro/Forms/personForm.dart';
import 'package:covid19_4ro/Model/birthday.dart';
import 'package:covid19_4ro/Model/person.dart';
import 'package:covid19_4ro/Repository/documentTextsRepository.dart';
import 'package:covid19_4ro/Repository/personRepository.dart';
import 'package:covid19_4ro/Repository/templateImageRepository.dart';
import 'package:flutter/material.dart';

import '../localizations.dart';

class PersonListState extends State<PersonListWidget> {
  final List<Person> _persons = <Person>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);

  @override
  void initState() {
    _loadState().then((value) {
      _persons.addAll(value);
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: getLocalizedText("Persons"),
      ),
      body: Center(
        child: _buildList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPersonCreator,
        child: Icon(Icons.plus_one),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _persons.length == 0 ? 0 : _persons.length * 2 - 1,
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }

          final int index = i ~/ 2;
          return _buildRow(_persons[index], index);
        });
  }

  Widget _buildRow(Person person, int index) {
    return Dismissible(
        key: Key(person.name),
        onDismissed: (direction) {
          setState(() {
            _deletePersonStateStatementTemplate(person);
            _persons.removeAt(index);
            _saveState(_persons);
          });
        },
        child: ListTile(
          title: Text(
            person.name,
            style: _biggerFont,
          ),
          trailing: IconButton(icon: Icon(Icons.edit), onPressed: () => _navigateToPersonEditor(person)),
        ));
  }

  void saveStateAndUpdateView() {
    _saveState(_persons);
    setState(() {});
  }

  Future<void> _navigateToPersonCreator() async {
    Person person = new Person('', '', new Birthday(DateTime.now()), null);
    var p = await _navigateTo(
      PersonWidget(person),
      getLocalizedValue("NewPerson"),
    );
    if (p != null) {
      _persons.add(p);
      saveStateAndUpdateView();
    }
  }

  Future<void> _navigateToPersonEditor(Person person) async {
    var p = await _navigateTo(PersonWidget(person), getLocalizedValue("PersonDetails"));
    if (p != null) {
      if (person.templateName != null && person.templateName != p.templateName) {
        _deletePersonStateStatementTemplate(person);
      }

      person.setFields(p);
      saveStateAndUpdateView();
    }
  }

  dynamic _navigateTo(StatefulWidget widget, String title) async {
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

  Future<List<Person>> _loadState() async {
    PersonRepository repo = new PersonRepository();

    var data = await repo.readData();
    return data;
  }

  Future<void> _saveState(List<Person> personList) async {
    await Future.forEach(personList.where((element) => element.personsStatementTemplete != null), (element) async {
      var documentTextsRepository = DocumentTextsRepository(element.templateName);
      await documentTextsRepository.writeData(element.personsStatementTemplete.documentElements);

      var templateImageRepository = TemplateImageRepository(element.templateName);
      await templateImageRepository.writeData(element.personsStatementTemplete.image);

      element.personsStatementTemplete = null;
    });

    PersonRepository repo = new PersonRepository();
    await repo.writeData(personList);
  }

  String getLocalizedValue(String key) => AppLocalizations.of(context).translate(key);
  Text getLocalizedText(String key) => Text(getLocalizedValue(key));
}

Future<void> _deletePersonStateStatementTemplate(Person person) async {
  var documentTextsRepository = DocumentTextsRepository(person.templateName);
  await documentTextsRepository.deleteRepository();

  var templateImageRepository = TemplateImageRepository(person.templateName);
  await templateImageRepository.deleteRepository();
}

class PersonListWidget extends StatefulWidget {
  @override
  PersonListState createState() => new PersonListState();
}
