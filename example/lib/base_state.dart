import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {

  showWarningDialog(String message) {
    Dialogs.materialDialog(
        context: context,
        msg: message,
        color: Colors.white,
        actionsBuilder: (context) => [
          IconsOutlineButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'OK',
            iconData: Icons.warning_amber,
            textStyle: const TextStyle(color: Colors.black),
            iconColor: Colors.orange.shade400,
          )
        ]);
  }

  showOkDialog(String message) {
    Dialogs.materialDialog(
        context: context,
        msg: message,
        color: Colors.white,
        actionsBuilder: (context) => [
          IconsOutlineButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'OK',
            iconData: Icons.info,
            textStyle: TextStyle(color: Colors.blue.shade400),
            iconColor: Colors.blue.shade400,
          )
        ]);
  }

  showErrorDialog(String message) {
    Dialogs.materialDialog(
        context: context,
        msg: message,
        color: Colors.white,
        actionsBuilder: (context) => [
          IconsOutlineButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'Cancel',
            iconData: Icons.error_outline,
            textStyle: const TextStyle(color: Colors.black),
            iconColor: Colors.red,
          )
        ]);
  }
}