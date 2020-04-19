import 'documentElement.dart';

class DocumentText extends DocumentElement {
  String text;
  double rotationAngle;
  DocumentText(double xOnPaper, double yOnPaper, this.text, this.rotationAngle) : super(xOnPaper, yOnPaper);

  DocumentText.fromJson(Map<String, dynamic> json)
      : text = json['textValue'],
        rotationAngle = json['rotationAngle'],
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> retVar = {'textValue': text, 'rotationAngle': rotationAngle};
    retVar.addAll(super.toJson());
    return retVar;
  }
}
