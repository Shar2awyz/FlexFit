import 'package:untitled6/services/services.dart';
import 'model/SignUpRequest.dart';

class SignUpRepository {
  final _auth = supa();

  Future<void> signUp(SignUpRequest request) {
    return _auth.signup(
      request.email,
      request.password,
      request.username,
      request.fullName,
      'Male',
    );
  }
}
