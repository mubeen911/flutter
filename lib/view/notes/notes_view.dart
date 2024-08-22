import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/constants/route.dart';
import 'package:notes/enums/menu_action.dart';

import 'package:notes/services/auth/auth_services.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_events.dart';
import 'package:notes/services/cloud/cloud_note.dart';

import 'package:notes/services/cloud/firebase_cloud_storage.dart';
import 'package:notes/utilities/dialoges/show_logout_dialog.dart';

import 'package:notes/view/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _noteServices;
  String get userId => AuthServices.firebase().currentUser!.id;
  @override
  void initState() {
    _noteServices = FirebaseCloudStorage();

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
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
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
                       if (context.mounted) {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                     
                      
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
        body: StreamBuilder(
            stream: _noteServices.allNotes(ownerUserId: userId),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    final allNotes = snapshot.data as Iterable<CloudNote>;
                    return NotesListView(
                      notes: allNotes,
                      onDeleteNote: (note) async {
                        await _noteServices.deleteNote(
                            documentId: note.documentId);
                      },
                      onTap: (note) {
                        Navigator.of(context).pushNamed(createOrUpdateNoteRoute,
                            arguments: note);
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }

                default:
                  return const CircularProgressIndicator();
              }
            }));
  }
}
