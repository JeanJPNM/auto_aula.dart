import 'package:auto_aula/providers/scrapper_provider.dart';
import 'package:auto_aula/providers/data_provider.dart';
import 'package:auto_aula/providers/theme_provider.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginDialog extends StatefulWidget {
  final DataNotifier dataNotifier;

  const LoginDialog({Key? key, required this.dataNotifier}) : super(key: key);
  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  late TextEditingController userController, passwordController;
  @override
  void initState() {
    userController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Informe o novo login'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            String? user = userController.text;
            String? password = passwordController.text;
            if (user.isEmpty) user = null;
            if (password.isEmpty) password = null;
            widget.dataNotifier.changeLogin(
              user: user,
              password: password,
            );
            Navigator.pop(context);
          },
          child: const Text('Pronto'),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: userController,
            decoration: const InputDecoration(labelText: 'Matrícula'),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'senha'),
          )
        ],
      ),
    );
  }
}

class Home extends StatelessWidget {
  void _changeLogin(BuildContext context, DataNotifier dataNotifier) {
    showDialog(
        context: context,
        builder: (context) {
          return LoginDialog(
            dataNotifier: dataNotifier,
          );
        });
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
              return SwitchListTile(
                value: theme.brightness == Brightness.dark,
                title: const Text('Tema escuro'),
                onChanged: (value) => _changeTheme(value, themeNotifier),
              );
            },
          ),
          const SizedBox(height: 20),
          Consumer(builder: (context, watch, _) {
            final dataNotifier = watch(dataProvider);
            return ElevatedButton(
              onPressed: () => _changeLogin(context, dataNotifier),
              child: const Text('Mudar login'),
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
    final Map<Pattern, String> messages = {
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
            int start = 0, currentClass = browserState.currentClass;
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
            late final String message = exception.toString();
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
