import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:notes/constants/route.dart';
import 'package:notes/utilities/show_error-dialogue.dart';

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
                    await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: password);
                       Navigator.of(context).pushNamed(verifyEmailRoute);
                    final user =  FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();
                    
                    
                  } on FirebaseAuthException catch (e) {
                   
                    if(context.mounted)
                    {
                    if (e.code == "weak-password") {
                      showerrorDialogue(context, "password is weak");
                    } else if (e.code == "email-already-in-use") {
                      showerrorDialogue(context, "emaail is already in use");
                    } else if (e.code == 'invalid-email') {
                      showerrorDialogue(context, 'invalid email');
                    }
                    else
                    {
                      showerrorDialogue(context, "Error: ${e.code}");
                    }
                    }
                  }
                  catch(e)
                  {
                    if(context.mounted)
                    {
                    showerrorDialogue(context, e.toString());}
                  }
                },
                child: const Text(
                  "Register",
                  style: TextStyle(color: Colors.blue),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, loginRoute, (context)=> false);
                },
                child: const Text(
                  "Already register? Login here",
                  style: TextStyle(color: Colors.blue),
                ))
          ],
        ));
  }
}
