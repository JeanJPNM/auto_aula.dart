import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _lightTheme = ThemeData(
  primarySwatch: Colors.blue,
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.cyan,
);

final themeProvider = StateNotifierProvider((_) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(_lightTheme);
  void useLightTheme() {
    if (state == _lightTheme) return;
    state = _lightTheme;
  }

  void useDarkTheme() {
    if (state == _darkTheme) return;
    state = _darkTheme;
  }
}
