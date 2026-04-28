class businesslogic{
  final emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  bool confirmpassword(String password,String passwordagain){
    return password==passwordagain;
  }
  bool isValidEmail(String email) {
    return emailRegex.hasMatch(email);
  }

}