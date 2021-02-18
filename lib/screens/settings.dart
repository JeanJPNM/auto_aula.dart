import 'package:auto_aula/providers/data_provider.dart';
import 'package:auto_aula/providers/theme_provider.dart';
import 'package:auto_aula/widgets/input_dialog.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _changeUser(
      BuildContext context, DataNotifier dataNotifier) async {
    final user = await showDialog(
        context: context,
        builder: (context) {
          return const InputDialog(title: Text('Nova matrícula'));
        }) as String?;
    if (user != null) {
      await dataNotifier.changeLogin(user: user);
    }
  }

  Future<void> _changePassword(
      BuildContext context, DataNotifier dataNotifier) async {
    final password = await showDialog(
        context: context,
        builder: (context) {
          return const InputDialog(title: Text('Nova senha'));
        }) as String?;
    if (password != null) {
      await dataNotifier.changeLogin(password: password);
    }
  }

  void _changeTheme(bool isDark, ThemeNotifier themeNotifier) {
    if (isDark) {
      themeNotifier.useDarkTheme();
    } else {
      themeNotifier.useLightTheme();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Consumer(builder: (context, watch, _) {
          final themeNotifier = watch(themeProvider);
          final themeState = watch(themeProvider.state);
          return SwitchListTile(
            value: themeState.brightness == Brightness.dark,
            title: const Text('Tema escuro'),
            onChanged: (value) => _changeTheme(value, themeNotifier),
          );
        }),
        const SizedBox(height: 20),
        Consumer(builder: (context, watch, _) {
          final dataNotifier = watch(dataProvider);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _changeUser(context, dataNotifier),
                child: const Text('Mudar matrícula'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _changePassword(context, dataNotifier),
                child: const Text('Mudar senha'),
              ),
            ],
          );
        }),
      ],
    );
  }
}
