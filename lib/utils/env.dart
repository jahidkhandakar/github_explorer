import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    await dotenv.load(fileName: ".env", isOptional: true);
  }

  static String? get githubPat {
    final v = dotenv.env['GITHUB_PAT']?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }
}