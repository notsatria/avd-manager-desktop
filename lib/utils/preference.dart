import 'package:shared_preferences/shared_preferences.dart';

final String _sdkPathKey = 'sdkPath';

class Preference {
  /// Saves the provided SDK path to shared preferences.
  static Future<void> saveSdkPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sdkPathKey, path);
  }

  /// Loads the SDK path from shared preferences, or uses the default if none is saved.
  static Future<String> loadSdkPath(String defaultSdkPath) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_sdkPathKey) ?? defaultSdkPath;
    return savedPath;
  }
}
