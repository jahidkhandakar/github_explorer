import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/theme_controller.dart';
import '../controller/auth_controller.dart';
import '../../utils/routes.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.put(ThemeController());
    final auth = Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Explorer'),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: const Icon(Icons.brightness_6),
            onPressed: themeCtrl.toggle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text(
              'Browse public and personal repos instantly',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.person),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Continue as Guest'),
              ),
              onPressed: AppNav.toGuestHome,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.lock),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Continue with GitHub'),
              ),
              onPressed: () async {
                try {
                  await auth.signInWithGithub();
                  AppNav.toAuthHome();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'No login required to explore public repos',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}