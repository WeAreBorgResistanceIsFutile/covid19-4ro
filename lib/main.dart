import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Forms/addressForm.dart';
import 'Lists/statementList.dart';
import 'Lists/personList.dart';
import 'statementTemplateWidget.dart';
import 'localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(supportedLocales: [
      Locale('ro', ''),
      Locale('hu', ''),
    ], localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ], title: "COVID-19 Statement", home: StatePresenter());
  }
}

class ApplicationState extends State<StatePresenter> {
  @override
  Widget build(BuildContext context) {
    StatementListWidget statementList = StatementListWidget();

    return Scaffold(
      // Add from here...
      appBar: AppBar(
        title: getLocalizedText('StatementListWidgetTitle'),
        actions: <Widget>[
          // Add 3 lines from here...
          IconButton(icon: Icon(Icons.input), onPressed: _navigateToImageTemplateViewer),
          IconButton(icon: Icon(Icons.person), onPressed: _navigateToPersonList),
          IconButton(icon: Icon(Icons.home), onPressed: _navigateToAddressEditor),
          IconButton(icon: Icon(Icons.info), onPressed: () => _showAlert(getLocalizedValue('InfoTitle'), getLocalizedValue('InfoMessage'))),
        ],
      ),
      body: statementList,
    );
  }

  void _navigateToImageTemplateViewer() {
    _navigateToScaffold(StatementTemplateWidget(), getLocalizedValue('StatementTemplateWidgetTitle'));
  }

  void _navigateToPersonList() {
    _navigateTo(PersonListWidget());
  }

  void _navigateToAddressEditor() {
    _navigateToScaffold(AddressWidget(), getLocalizedValue('AddressWidgetTitle'));
  }

  void _showAlert(String title, String message) async {
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
              child: Icon(Icons.mail),
              onPressed: () {
                launch("mailto:zoldeper@gmail.com?subject=COVID-19 app&body=");
              },
            ),
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

  dynamic _navigateTo(StatefulWidget widget) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) {
        return Center(child: widget);
      }),
    );
    return result;
  }

  String getLocalizedValue(String key) => AppLocalizations.of(context).translate(key);
  Text getLocalizedText(String key) => Text(getLocalizedValue(key));
}

class StatePresenter extends StatefulWidget {
  @override
  ApplicationState createState() => new ApplicationState();
}
