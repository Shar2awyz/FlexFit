import 'package:shared_preferences/shared_preferences.dart';
class sharedprefs{
Future<void> saveUserId(String userid) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userid', userid);
}
Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userid');
}

Future<void> clearUserId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userid');
}}