import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'Model/address.dart';
import 'Model/person.dart';
import 'Model/statementOnYourLiability.dart';
import 'documentTemplateProcessor.dart';
import 'localizations.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StatementGenerator {
  BuildContext context;
  StatementOnYourLiability statement;

  StatementGenerator(this.context, this.statement);

  Future<void> generateStatements(List<Person> persons, Address address) async {
    if (await getPermissionsStatus()) {
      ProgressDialog pr = _buildProgressDialog();
      try {
        await pr.show();
        pr.update(progress: 0, message: getLocalizedValue("StatementGenerationInProgress"));

        for (var i = 0; i < persons.length; i++) {
          var person = persons[i];
          var templateProcessor = new DocumentTemplateProcessor();
          await templateProcessor.loadTemplate(person.templateName);

          templateProcessor.documentTemplate.initializePersponalInformation(person);
          templateProcessor.documentTemplate.initializeAddressInformation(address);
          templateProcessor.documentTemplate.initializeStatementInformation(statement);

          if (templateProcessor.isImageLoaded) {
            var imageToBeDisplayed = templateProcessor.decorateImageWithText();

            var jpeg = img.encodeJpg(imageToBeDisplayed);

            await _saveImageToGalery(jpeg);

            var message = getLocalizedValue("StatementGenerated").replaceAll("#", person.name);
            pr.update(progress: (((i + 1) / persons.length) * 100).roundToDouble(), message: message);
          }
        }

        pr.update(progress: 100, message: getLocalizedValue("StatementGenerationEnded"));
        if (pr != null && pr.isShowing()) pr.hide();
      } catch (e) {
        if (pr != null && pr.isShowing()) pr.hide();
      }
    }    
  }

  Future<void> _saveImageToGalery(List<int> data) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg';
    await File(filePath).writeAsBytes(data);

    if (await getPermissionsStatus()) await GallerySaver.saveImage(filePath);
  }

  ProgressDialog _buildProgressDialog() {
    var pr = ProgressDialog(context, type: ProgressDialogType.Download, isDismissible: false);
    pr.style(progress: 0, maxProgress: 100);
    return pr;
  }

  Future<bool> getPermissionsStatus() async {
    var permission = Platform.isAndroid ? PermissionGroup.storage : PermissionGroup.photos;

    final PermissionHandler _permissionHandler = PermissionHandler();

    var status = await _permissionHandler.checkPermissionStatus(permission);
    if (status != PermissionStatus.granted) {
      await _showAlert(getLocalizedValue('oops'), getLocalizedValue('NO_EXTERNAL_STORAGE_WRITE_PERMISSION'));
      await _permissionHandler.requestPermissions([permission]);
      status = await _permissionHandler.checkPermissionStatus(permission);
    }
    return status == PermissionStatus.granted;
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
