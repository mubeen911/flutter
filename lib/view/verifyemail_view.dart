
import 'package:flutter/material.dart';
import 'package:notes/constants/route.dart';
import 'package:notes/services/auth/auth_services.dart';

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
                  await AuthServices.firebase().sendEmailVerification();
                },
                child: const Text(
                  'Send email verification',
                  style: TextStyle(color: Colors.blue),
                )),
                TextButton(onPressed: ()
               async {
                 await AuthServices.firebase().logout();
                 if(context.mounted)
                 {
                  Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (_)=>false);
                 }
                }, child: const Text("Restart",style: TextStyle(color: Colors.blue),))
          ],
        ),
    );
    
  }
}
