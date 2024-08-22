import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/auth_exception.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_events.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialoges/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state)async {
        if(state is AuthStateRegistering)
        {
          
         
          if (state.exception is WeakPasswordAuthException)
          {
            await showerrorDialogue(context, 'password is weak');
          }
           if (state.exception is EmailAlreadyInUseAuthException)
          {
             if(context.mounted)
            {
            await showerrorDialogue(context, "email is already in use");
            }
          }

           if (state.exception is InvalidEmailAuthException)
          {
              if(context.mounted)
            {
            await showerrorDialogue(context, "invalid email");
          }
          }

           if (state.exception is GenericAuthException)
          {
              if(context.mounted)
            {
            await showerrorDialogue(context, "Failed to register");
          }
          }
            
        }
      },
      child: Scaffold(
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
                     final email = _email.text;
                      final password = _password.text;
                   context.read<AuthBloc>().add( AuthEventRegister(email, password));
                    
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.blue),
                  )),
              TextButton(
                  onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text(
                    "Already register? Login here",
                    style: TextStyle(color: Colors.blue),
                  ))
            ],
          )),
    );
  }
}
