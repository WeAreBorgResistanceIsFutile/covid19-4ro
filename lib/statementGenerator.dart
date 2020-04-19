
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:progress_dialog/progress_dialog.dart';

import 'Model/address.dart';
import 'Model/person.dart';
import 'Model/statementOnYourLiability.dart';
import 'documentTemplateProcessor.dart';
import 'localizations.dart';

class StatementGenerator {
  BuildContext context;
  StatementOnYourLiability statement;

  StatementGenerator(this.context, this.statement);

  Future<void> generateStatements(List<Person> persons, Address address, Future<void> _saveImageToGalery(List<int> image))  async {
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

  ProgressDialog _buildProgressDialog() {
    var pr = ProgressDialog(context, type: ProgressDialogType.Download, isDismissible: false);
    pr.style(progress: 0, maxProgress: 100);
    return pr;
  }

  String getLocalizedValue(String key) => AppLocalizations.of(context).translate(key);
  Text getLocalizedText(String key) => Text(getLocalizedValue(key));
}
