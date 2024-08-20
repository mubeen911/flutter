
import 'package:flutter/material.dart';
import 'package:notes/utilities/dialoges/generic_dialog.dart';

Future<void> showCannotShareEmptyDialog( BuildContext context)
{
  return showGenericDialog<void>(context: context, title: 'Share', content: "Cannot share Empty Dialog!", optionBuilder: ()=> {'OK':null}) ;
}