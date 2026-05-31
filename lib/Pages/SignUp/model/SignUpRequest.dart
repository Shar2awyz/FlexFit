class SignUpRequest {
  final String email;
  final String password;
  final String username;
  final String fullName;

  const SignUpRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.fullName,
  });
}
