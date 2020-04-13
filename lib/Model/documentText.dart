import 'documentElement.dart';

class DocumentText extends DocumentElement {
  String text;
  DocumentText(double xOnPaper, double yOnPaper, this.text) : super(xOnPaper, yOnPaper);

  DocumentText.fromJson(Map<String, dynamic> json)
      : text = json['textValue'],
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> retVar = {'textValue': text};
    retVar.addAll(super.toJson());
    return retVar;
  }
}
