import 'package:auto_aula/util/persistent_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

ThemeData get _lightTheme => ThemeData(
      primarySwatch: Colors.indigo,
    );

ThemeData get _darkTheme => ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.cyan,
    );

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeData>((_) => ThemeNotifier());

class ThemeNotifier extends PersistentStateNotifier<ThemeData> {
  ThemeNotifier() : super(_lightTheme);
  void useLightTheme() {
    if (state.brightness == Brightness.light) return;
    state = _lightTheme;
  }

  void useDarkTheme() {
    if (state.brightness == Brightness.dark) return;
    state = _darkTheme;
  }

  @override
  ThemeData fromMap(Map<String, dynamic> map) {
    if (map['theme'] == 'dark') {
      return _darkTheme;
    } else {
      return _lightTheme;
    }
  }

  @override
  Map<String, dynamic> toMap(ThemeData state) {
    var theme = 'light';
    if (state.brightness == Brightness.dark) theme = 'dark';
    return {
      'theme': theme,
    };
  }
}
