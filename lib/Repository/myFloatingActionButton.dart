import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatefulWidget {
  final Function whileButtonPressed;
  final Icon icon;
  final Color backgroundColor;
  MyFloatingActionButton(this.icon, this.backgroundColor, this.whileButtonPressed);
  @override
  _MyFloatingActionButtonState createState() => _MyFloatingActionButtonState();
}

class _MyFloatingActionButtonState extends State<MyFloatingActionButton> {
  bool buttonPressed = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: (new UniqueKey()).toString(),
      onPressed: onPressed,
      child: GestureDetector(
        child: widget.icon,
        onLongPressStart: pressStart,
        onLongPressEnd: pressEnd,
      ),
      backgroundColor: widget.backgroundColor,
    );
  }

  void onPressed() {
    if (widget.whileButtonPressed != null) widget.whileButtonPressed();
  }

  Future<void> pressStart(LongPressStartDetails details) async {
    buttonPressed = true;
    while (buttonPressed) {
      if (widget.whileButtonPressed != null) widget.whileButtonPressed();
      await Future.delayed(Duration(milliseconds: 10));
    }
  }

  void pressEnd(LongPressEndDetails details) {
    buttonPressed = false;
  }
}
