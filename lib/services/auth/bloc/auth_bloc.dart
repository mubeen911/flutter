import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_events.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvents, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventForgetPassword>((event, emit) {
      emit(const AuthStateForgetPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
      final email = event.email;
      if (email == null) {
        return;//user just want to go to forget password screen
      }

      emit(const AuthStateForgetPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));//user  want to actually send a forget password email

bool didSendEmail;
Exception? exception;
      try {
        provider.sendPasswordReset(toEmail: email);
        didSendEmail=true;
        exception=null;
      } on Exception catch (e) {
        didSendEmail=false;
        exception=e;
      }

      emit( AuthStateForgetPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: true,
      ));
    });


    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

  on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });
    on<AuthEventsInitialize>((event, emit) async {
      //initialize
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'please wait while I log you  in',
      ));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.login(
          email: email,
          password: password,
        );
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        }
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logout();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}
