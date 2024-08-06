
//login exceptions
class UserNotFoundAuthException implements Exception{}

//
// Register exceptions
class WeakPasswordAuthException implements Exception{}
class EmailAlreadyInUseAuthException implements Exception{}
//
//Generic auth exception
class GenericAuthException implements Exception {}
class InvalidEmailAuthException implements Exception{}
class UserNotLoggedInAuthException implements Exception{}
