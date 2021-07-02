import 'package:auto_aula/providers/data_provider.dart';
import 'package:auto_aula/providers/theme_provider.dart';
import 'package:auto_aula/util/extensions.dart';
import 'package:auto_aula/widgets/duration_picker.dart';
import 'package:auto_aula/widgets/input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      await dataNotifier.update(user: user);
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
      await dataNotifier.update(password: password);
    }
  }

  void _changeTheme(bool isDark, ThemeNotifier themeNotifier) {
    if (isDark) {
      themeNotifier.useDarkTheme();
    } else {
      themeNotifier.useLightTheme();
    }
  }

  Future<void> _changeTimeout(
    BuildContext context,
    DataNotifier dataNotifier,
  ) async {
    final timeout = await showDialog<Duration?>(
      context: context,
      builder: (context) =>
          const DurationPicker(title: 'Selecione o novo timeout'),
      barrierDismissible: false,
    );
    if (timeout == null) return;
    await dataNotifier.update(timeoutDuration: timeout);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Consumer(builder: (context, watch, _) {
          final themeNotifier = watch(themeProvider.notifier);
          final themeState = watch(themeProvider);
          return SwitchListTile(
            value: themeState.brightness == Brightness.dark,
            title: const Text('Tema escuro'),
            onChanged: (value) => _changeTheme(value, themeNotifier),
          );
        }),
        Consumer(builder: (context, watch, _) {
          final dataNotifier = watch(dataProvider.notifier);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                onTap: () => _changeUser(context, dataNotifier),
                title: const Text('Mudar matrícula'),
              ),
              ListTile(
                onTap: () => _changePassword(context, dataNotifier),
                title: const Text('Mudar senha'),
              ),
            ],
          );
        }),
        Consumer(
          builder: (context, watch, _) {
            final dataNotifier = watch(dataProvider.notifier);
            final dataState = watch(dataProvider);
            final duration = dataState is UserData
                ? dataState.timeoutDuration
                : const Duration(minutes: 1);
            return ListTile(
              title: const Text('Alterar a duração do tempo limite'),
              subtitle: Text('Atual: ${duration.toLocaleString()}'),
              onTap: () => _changeTimeout(context, dataNotifier),
            );
          },
        )
      ],
    );
  }
}
