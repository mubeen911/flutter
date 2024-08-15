import 'package:flutter/material.dart';
import 'package:notes/utilities/dialoges/generic_dialog.dart';

Future<bool> showDeleteDialogue(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: 'Delete dialogue',
      content: 'Are you sure you want to delete dialog!',
      optionBuilder: () => {'Cancel': false, 'Delete': true}).then(
    (value) => value ?? false,
  );
}
