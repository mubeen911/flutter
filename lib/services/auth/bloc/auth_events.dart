import 'package:flutter/material.dart' show immutable;

@immutable
abstract class AuthEvents {
  const AuthEvents();
}

class AuthEventSendEmailVerification extends AuthEvents {
  const AuthEventSendEmailVerification();
}

class AuthEventsInitialize extends AuthEvents {
  const AuthEventsInitialize();
}

class AuthEventLogIn extends AuthEvents {
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogOut extends AuthEvents {
  const AuthEventLogOut();
}

class AuthEventRegister extends AuthEvents {
  final String email;
  final String password;
  const AuthEventRegister(
    this.email,
    this.password,
  );
}

class AuthEventForgetPassword extends AuthEvents{
final String? email;
const AuthEventForgetPassword({this.email});
}

class AuthEventShouldRegister extends AuthEvents {
  const AuthEventShouldRegister();
}
