import 'package:flutter/material.dart';
import 'package:notes/utilities/dialoges/generic_dialog.dart';

Future<void> showerrorDialogue(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
      context: context,
      title: 'An error ocurred',
      content: text,
      optionBuilder: () => {'OK': null});
}

