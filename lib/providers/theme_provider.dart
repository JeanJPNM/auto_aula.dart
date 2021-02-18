import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_riverpod/flutter_riverpod.dart';

ThemeData get _lightTheme => ThemeData(
      primarySwatch: Colors.indigo,
    );

ThemeData get _darkTheme => ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.cyan,
    );

final themeProvider = StateNotifierProvider((_) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(_lightTheme);
  void useLightTheme() {
    if (state.brightness == Brightness.light) return;
    state = _lightTheme;
  }

  void useDarkTheme() {
    if (state.brightness == Brightness.dark) return;
    state = _darkTheme;
  }
}
