
import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:notes/constants/route.dart';

import 'package:notes/enums/menu_action.dart';
import 'package:notes/services/auth/auth_services.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notes View",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<MenuAction>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final logout = await showlogoutdialogue(context);
                  log(logout.toString());
                  if (logout) {
                    await AuthServices.firebase().logout();
                    if(context.mounted)
                    {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);}
                  }

                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("log out"),
                )
              ];
            },
          )
        ],
      ),
    );
  }
}

Future<bool> showlogoutdialogue(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text("Are you sure, you want to log out"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel",style: TextStyle(color: Colors.black),)),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Log out",style: TextStyle(color: Colors.black),))
          ],
        );
      }).then((value) => value ?? false);
}
