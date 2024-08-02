
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => __VerifyEmailViewStateState();
}

class __VerifyEmailViewStateState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title:const  Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
          children: <Widget>[
            const Text("Please verify your email"),
            TextButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  user?.sendEmailVerification();
                },
                child: const Text(
                  'Send email verification',
                  style: TextStyle(color: Colors.blue),
                ))
          ],
        ),
    );
    
  }
}
