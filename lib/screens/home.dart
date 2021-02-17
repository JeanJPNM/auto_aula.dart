import 'package:auto_aula/providers/scrapper_provider.dart';
import 'package:auto_aula/providers/data_provider.dart';
import 'package:auto_aula/providers/theme_provider.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InputDialog extends StatefulWidget {
  const InputDialog({
    required this.title,
    this.initialText,
    this.inputLabel,
  });
  final Widget title;
  final String? initialText;
  final String? inputLabel;
  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController(text: widget.initialText);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Pronto'),
        ),
      ],
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: widget.inputLabel,
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  Future<void> _changeUser(
      BuildContext context, DataNotifier dataNotifier) async {
    final user = await showDialog(
        context: context,
        builder: (context) {
          return const InputDialog(title: Text('Nova matrícula'));
        }) as String?;
    await dataNotifier.changeLogin(user: user);
  }

  Future<void> _changePassword(
      BuildContext context, DataNotifier dataNotifier) async {
    final password = await showDialog(
        context: context,
        builder: (context) {
          return const InputDialog(title: Text('Nova senha'));
        }) as String?;
    await dataNotifier.changeLogin(password: password);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Aula'),
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, watch, _) {
              final themeNotifier = watch(themeProvider);
              final theme = watch(themeProvider.state);
              return Center(
                child: SwitchListTile(
                  value: theme.brightness == Brightness.dark,
                  title: const Text('Tema escuro'),
                  onChanged: (value) => _changeTheme(value, themeNotifier),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Consumer(builder: (context, watch, _) {
            final dataNotifier = watch(dataProvider);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => _changeUser(context, dataNotifier),
                  child: const Text('Mudar matrícula'),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => _changePassword(context, dataNotifier),
                  child: const Text('Mudar senha'),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          const _OnlineProgress(),
        ],
      ),
    );
  }
}

class _OnlineProgress extends StatefulWidget {
  const _OnlineProgress();
  @override
  __OnlineProgressState createState() => __OnlineProgressState();
}

class __OnlineProgressState extends State<_OnlineProgress> {
  late TextEditingController userController, passwordController;

  @override
  void initState() {
    userController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  String? _convertErrorMessage(String message) {
    final messages = <Pattern, String>{
      'browser has disconnected': 'Conexão com o navegador perdida!',
      'Login Inválido': 'Login Inválido!',
      'Websocket url not found':
          'Uma sessão anterior do navegador está bloqueando o programa!'
    };
    for (final entry in messages.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, _) {
        final browserNotifier = watch(browserProvider);
        final browserState = watch(browserProvider.state);
        final dataNotifier = watch(dataProvider);
        final dataState = watch(dataProvider.state);
        if (dataState is InitialData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (dataState is UserData) {
          if (dataState.user == null || dataState.password == null) {
            return Center(
              child: Column(
                children: [
                  TextField(
                    controller: userController,
                    decoration: const InputDecoration(labelText: 'Matrícula'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Senha'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      dataNotifier.changeLogin(
                        user: userController.text,
                        password: passwordController.text,
                      );
                    },
                    child: const Text('Pronto'),
                  )
                ],
              ),
            );
          }
          if (browserState is ScrapperIdle) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  browserNotifier.start();
                },
                child: const Text('Assistir às aulas'),
              ),
            );
          } else if (browserState is LaunchingScrapper) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (browserState is WatchingClasses) {
            final day = DateTime.now().weekday;
            var start = 0, currentClass = browserState.currentClass;
            if (day == 2 || day == 4) {
              start++;
              currentClass++;
            }
            return Center(
              child: Column(
                children: [
                  for (var i = start; i < 6; i++)
                    ListTile(
                      title: Text('Aula ${i + 1}'),
                      trailing: currentClass >= i
                          ? const Icon(Icons.done)
                          : const CircularProgressIndicator(),
                    )
                ],
              ),
            );
          } else if (browserState is ScrapperException) {
            final exception = browserState.exception;
            late final message = exception.toString();
            return Center(
              child: Column(
                children: [
                  const Text('Ocorreu um erro: '),
                  Text(_convertErrorMessage(message) ?? message),
                  ElevatedButton(
                    onPressed: () => browserNotifier.start(),
                    child: const Text('Tentar novamente'),
                  )
                ],
              ),
            );
          }
        }
        return const Center(child: Text('Erro'));
      },
    );
  }
}
