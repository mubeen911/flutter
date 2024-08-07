import 'package:flutter/material.dart';
import 'package:notes/constants/route.dart';
import 'package:notes/services/auth/auth_exception.dart';
import 'package:notes/services/auth/auth_services.dart';
import 'package:notes/utilities/show_error_dialogue.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
            "Register",
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
              decoration:
                  const InputDecoration(hintText: "Enter your password"),
            ),
            TextButton(
                onPressed: () async {
                  try {
                    final email = _email.text;
                    final password = _password.text;
                    await AuthServices.firebase()
                        .createUser(email: email, password: password);
                    await AuthServices.firebase().sendEmailVerification();
                    if (context.mounted) {
                      Navigator.of(context).pushNamed(verifyEmailRoute);
                    }
                  } on WeakPasswordAuthException {
                    if (context.mounted) {
                      showerrorDialogue(context, "password is weak");
                    }
                  } on EmailAlreadyInUseAuthException {
                    if (context.mounted) {
                      showerrorDialogue(context, "email is already in use");
                    }
                  } on InvalidEmailAuthException {
                    if (context.mounted) {
                      showerrorDialogue(context, "invalid email");
                    }
                  } on GenericAuthException {
                    if (context.mounted) {
                      showerrorDialogue(context, "Failed to register");
                    }
                  }
                },
                child: const Text(
                  "Register",
                  style: TextStyle(color: Colors.blue),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, loginRoute, (context) => false);
                },
                child: const Text(
                  "Already register? Login here",
                  style: TextStyle(color: Colors.blue),
                ))
          ],
        ));
  }
}
