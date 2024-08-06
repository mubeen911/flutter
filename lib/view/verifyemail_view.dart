
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/route.dart';

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
          "Email Verification",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
          children: <Widget>[
            const Text('We have sent you an email verification, please open it to verify your account'),
            const Text("If you han'nt recieved an email verificaton, press buttin below"),
            TextButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                 await  user?.sendEmailVerification();
                },
                child: const Text(
                  'Send email verification',
                  style: TextStyle(color: Colors.blue),
                )),
                TextButton(onPressed: ()
                {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (_)=>false);
                }, child: const Text("Restart",style: TextStyle(color: Colors.blue),))
          ],
        ),
    );
    
  }
}
