import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import "package:notes/constants/route.dart";
import "package:notes/services/auth/bloc/auth_bloc.dart";
import "package:notes/services/auth/bloc/auth_events.dart";
import "package:notes/services/auth/bloc/auth_state.dart";
import "package:notes/services/auth/firebase_auth_provider.dart";
import "package:notes/view/login_view.dart";
import "package:notes/view/notes/create_update_note_view.dart";
import "package:notes/view/notes/notes_view.dart";
import "package:notes/view/register_view.dart";
import "package:notes/view/verifyemail_view.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
      createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView()
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventsInitialize());
    return BlocBuilder<AuthBloc,AuthState>(
      builder: (context, state) {
       if(state is AuthStateLoggedIn)
       {
        return const NotesView();
       }
       else if(state is AuthStateNeedsVerification)
       {
        return const VerifyEmailView();
       }
       else if(state is AuthStateLoggedOut)
       {
        return const LoginView();
       }
       else{
        return const  Scaffold(
          body:CircularProgressIndicator() ,
        );
       }
      },
    );
   
}
}