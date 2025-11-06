import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:github_explorer/mvc/controller/auth_controller.dart';
import 'firebase_options.dart';
import 'utils/routes.dart';
import 'utils/theme.dart';
import 'mvc/controller/theme_controller.dart';
import 'utils/env.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Env.load();
  debugPrint('🔑 PAT loaded? ${Env.githubPat?.substring(0, 6) ?? "null"}...');
  await GetStorage.init(); // cache
  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub Explorer',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeCtrl.themeMode.value,
      initialRoute: Routes.welcome,
      getPages: Routes.pages,
    ));
  }
}