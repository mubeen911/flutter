import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:notes/constants/route.dart';
import 'package:notes/services/auth/auth_exception.dart';
import 'package:notes/services/auth/auth_services.dart';
import 'package:notes/utilities/show_error_dialogue.dart';

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
          TextButton(
              onPressed: () async {
                try {
                  final email = _email.text;
                  final password = _password.text;

                  final userCredentials = await AuthServices.firebase()
                      .login(email: email, password: password);

                  log(userCredentials.toString());
                  final user = AuthServices.firebase().currentUser;

                  if (context.mounted) {
                    if (user?.isEmailVerified ?? false) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(notesRoute, (_) => false);
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          verifyEmailRoute, (_) => false);
                    }
                  }
                } on UserNotFoundAuthException {
                  if (context.mounted) {
                    await showerrorDialogue(
                      context,
                      "User not found /invalid-credential",
                    );
                  }
                } on InvalidEmailAuthException {
                  if (context.mounted) {
                    await showerrorDialogue(
                        context, 'The email address is badly formatted');
                  }
                } on GenericAuthException {
                  if (context.mounted) {
                    await showerrorDialogue(context, 'Authentication error');
                  }
                }
              },
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.blue),
              )),
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
