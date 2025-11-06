import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/theme_controller.dart';
import '../controller/auth_controller.dart';
import '../../utils/routes.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final auth = Get.find<AuthController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'GitHub Explorer',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: const Icon(Icons.brightness_6_rounded),
            onPressed: themeCtrl.toggle,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        scheme.primary.withOpacity(0.25),
                        scheme.surfaceContainerHighest.withOpacity(0.35),
                      ]
                    : [
                        scheme.primaryContainer.withOpacity(0.9),
                        scheme.inversePrimary.withOpacity(0.9),
                      ],
              ),
            ),
          ),
          // Decorative blurred blobs
          Positioned(
            top: -40,
            left: -30,
            child: _BlurBlob(
              color: scheme.primary.withOpacity(0.35),
              size: 180,
              blur: 40,
            ),
          ),
          Positioned(
            bottom: -30,
            right: -20,
            child: _BlurBlob(
              color: scheme.secondaryContainer.withOpacity(0.4),
              size: 200,
              blur: 36,
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: scheme.primary.withOpacity(0.12),
                          child: Icon(
                            Icons.explore_rounded,
                            color: scheme.primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'GitHub Explorer',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse public and personal repositories with a clean, fast UI.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.85),
                              ),
                        ),
                        const SizedBox(height: 28),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.person_outline_rounded),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          label: const Text('Continue as Guest'),
                          onPressed: AppNav.toGuestHome,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          icon: const Icon(Icons.login_rounded),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          label: const Text('Continue with GitHub'),
                          onPressed: () async {
                            try {
                              await auth.signInWithGithub();
                              AppNav.toAuthHome();
                            } catch (e) {
                              debugPrint('🔥 Login failed: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login failed: $e')),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No login required to explore public repos',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: scheme.surface.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final double blur;
  final Color color;

  const _BlurBlob({
    required this.size,
    required this.blur,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}
