import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/constants/route.dart';
import 'package:notes/services/auth/auth_exception.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_events.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialoges/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          TextField(
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            controller: _email,
            decoration: const InputDecoration(hintText: "Enter your email"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter your password"),
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state)async {
              if(state is AuthStateLoggedOut)
              {
              if(state.exception  is UserNotFoundAuthException) 
              {
                await showerrorDialogue(context, 'User not found /invalid-credential');

              }
              else if( state.exception is InvalidEmailAuthException)
              {
                  await showerrorDialogue(context, "User not found /invalid-credential");
              }
              else if( state.exception is GenericAuthException)
              {
                  await showerrorDialogue(context, 'Authentication error');
              }
              }
            },
            child: TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  context
                        .read<AuthBloc>()
                        .add(AuthEventLogIn(email, password));
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.blue),
                )),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text(
                "Not registered yet? Register here",
                style: TextStyle(color: Colors.blue),
              ))
        ],
      ),
    );
  }
}
