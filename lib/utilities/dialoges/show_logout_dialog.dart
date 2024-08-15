import 'package:flutter/material.dart';
import 'package:notes/utilities/dialoges/generic_dialog.dart';

Future<bool> showlogoutdialogue(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: 'Log out',
      content: 'Are you sure you want to log out!',
      optionBuilder: () => {'Cancel': false, 'Log out': true}).then(
    (value) => value ?? false,
  );
}
