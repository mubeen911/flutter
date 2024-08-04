import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/constants/route.dart';
import 'package:notes/utilities/show_error-dialogue.dart';

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

                  final userCredentials = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password);

                  log(userCredentials.toString());
                 if(context.mounted)
                 {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(notesRoute, (_) => false);
                 }
                } on FirebaseAuthException catch (e) {
                  if(context.mounted)
                  {
                  if (e.code == 'invalid-credential') {
                    await showerrorDialogue(
                      context,
                      "User not found /invalid-credential",
                    );
                  } else if (e.code == 'invalid-email') {
                    await showerrorDialogue(
                        context, 'The email address is badly formatted');
                  } else {
                    await showerrorDialogue(context, 'Error:${e.code}');
                  }
                  }
                } catch (e) {
                  if (context.mounted)
                  {
                  await showerrorDialogue(context, e.toString());
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
