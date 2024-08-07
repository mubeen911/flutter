
import "package:notes/services/auth/auth_provider.dart";
import "package:notes/services/auth/auth_user.dart";
import "package:notes/services/auth/firebase_auth_provider.dart";

class AuthServices implements AuthProvider {
  final AuthProvider provider;
  AuthServices(this.provider);
 factory AuthServices.firebase()=> AuthServices(FirebaseAuthProvider());
  @override
  Future<AuthUser> createUser(
          {required String email, required String password}) =>
      provider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> login({required String email, required String password}) =>
      provider.login(email: email, password: password);

  @override
  Future<void> logout() => provider.logout();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
  
  @override
  Future<void> initialize()=> provider.initialize();
}
