import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:notes/constants/route.dart';
import 'package:notes/enums/menu_action.dart';
import 'package:notes/services/auth/auth_services.dart';
import 'package:notes/services/crud/notes_services.dart';
import 'package:notes/utilities/dialoges/show_logout_dialog.dart';
import 'package:notes/view/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesServices _noteServices;
  String get userEmail => AuthServices.firebase().currentUser!.email!;
  @override
  void initState() {
    _noteServices = NotesServices();

    super.initState();
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
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNotesRoute);
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              )),
          PopupMenuButton<MenuAction>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final logout = await showlogoutdialogue(context);
                  log(logout.toString());
                  if (logout) {
                    await AuthServices.firebase().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    }
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
      body: FutureBuilder(
          future: _noteServices.getorcreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    stream: _noteServices.allNotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            final allNotes =
                                snapshot.data as List<DatabaseNotes>;
                            return NotesListView(
                                notes: allNotes, onDeleteNote: (note) async {
                                  await _noteServices.deleteNote(id: note.id);
                                });
                          } else {
                            return const CircularProgressIndicator();
                          }

                        default:
                          return const CircularProgressIndicator();
                      }
                    });
              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }
}
