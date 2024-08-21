import 'package:flutter/material.dart' show immutable;

@immutable
abstract class AuthEvents {
  const AuthEvents();
}
class AuthEventsInitialize extends AuthEvents{
  const AuthEventsInitialize();
}
class AuthEventLogIn extends AuthEvents{
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}
class AuthEventLogOut extends AuthEvents{
  const AuthEventLogOut();
}