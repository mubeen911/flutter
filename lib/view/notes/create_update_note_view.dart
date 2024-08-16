import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_services.dart';
import 'package:notes/services/crud/notes_services.dart';
import 'package:notes/utilities/generics/get_arguement.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNotes? _note;
  late final NotesServices _notesServices;
  late final TextEditingController _textController;

  Future<DatabaseNotes> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArguement<DatabaseNotes>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthServices.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesServices.getUser(email: email);
    final newNote = await _notesServices.createNotes(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _textControllerListner() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesServices.updateNotes(note: note, text: text);
  }

  void _setUpTextControllerListner() {
    _textController.removeListener(_textControllerListner);
    _textController.addListener(_textControllerListner);
  }

  void _deleteNoteIfTextIsNotEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesServices.deleteNote(id: note.id);
    }
  }

  void _safeNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (text.isNotEmpty && note != null) {
      await _notesServices.updateNotes(note: note, text: text);
    }
  }

  @override
  void initState() {
    _notesServices = NotesServices();
    _textController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsNotEmpty();
    _safeNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'New Notes',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: FutureBuilder(
            future: createOrGetExistingNote(context),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  _setUpTextControllerListner();
                  return TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "Start writing note here...",
                    ),
                  );
                default:
                  return const CircularProgressIndicator();
              }
            }));
  }
}
