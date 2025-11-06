import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static const _key = 'theme_mode'; // 'light' or 'dark'
  final _box = GetStorage();

  // Two modes: light / dark (no system confusion)
  final themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read<String>(_key);

    if (saved == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else {
      // default fallback → light
      themeMode.value = ThemeMode.light;
      _box.write(_key, 'light');
    }
  }

  void toggle() {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
      _box.write(_key, 'dark');
    } else {
      themeMode.value = ThemeMode.light;
      _box.write(_key, 'light');
    }
    debugPrint('🌓 Theme toggled → ${themeMode.value}');
  }

  bool get isDark => themeMode.value == ThemeMode.dark;
}
