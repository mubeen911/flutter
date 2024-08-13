
import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:notes/constants/route.dart';

import 'package:notes/enums/menu_action.dart';
import 'package:notes/services/auth/auth_services.dart';
import 'package:notes/services/crud/notes_services.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

late final NotesServices _noteServices;
  String  get userEmail=>AuthServices.firebase().currentUser!.email!;
@override
void initState()
{

  _noteServices=NotesServices();

    super.initState();
 
}
@override
  void dispose()
{
  _noteServices.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Notes",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).pushNamed(newNotesRoute);
          }, icon: const Icon(Icons.add, color: Colors.white,)),
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
      body: FutureBuilder(future: _noteServices.getorcreateUser(email: userEmail), builder: (context, snapshot)
      {
        switch (snapshot.connectionState)
        {
        
          case ConnectionState.done:
            return StreamBuilder(stream: _noteServices.allNotes, builder: (context,snapshot)
            {
              switch(snapshot.connectionState)
              {
                
                case ConnectionState.none:
                
                case ConnectionState.waiting:
                  return const Text("Waiting for all Notes...");
               
                default:
                return  const CircularProgressIndicator();
              }
            });
            default: return const CircularProgressIndicator();
        }
      }),
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
