import 'package:flutter/material.dart';

class FormHelper
{
  Padding builTextField(TextEditingController controller, String hint,
      String messageIfValueEmpthy, double padding) {
    return Padding(
        padding: EdgeInsets.all(padding),
        child: TextFormField(
          decoration: new InputDecoration(
            hintText: hint,
          ),
          controller: controller,
          validator: (value) {
            return value.isEmpty ? messageIfValueEmpthy : null;
          },
        ));
  }
}