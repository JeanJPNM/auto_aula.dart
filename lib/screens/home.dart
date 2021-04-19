import 'package:auto_aula/providers/scrapper_provider.dart';
import 'package:auto_aula/providers/data_provider.dart';
import 'package:auto_aula/widgets/input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      body: Column(
        children: const [
          SizedBox(height: 20),
          _OnlineProgress(),
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
      'browser has disconnected':
          'Conexão com o navegador perdida, tente novamente.',
      'Session closed': 'A sessão foi fechada, tente novamente.',
      'Invalid login':
          'Login inválido, por favor troque sua matrícula e/ou sua senha',
      RegExp('ERR_CONNECTION_TIMED_OUT|Timeout Exceeded'):
          'A página demorou demais para responder, tente novamente',
      'Websocket url not found':
          'Uma sessão anterior do navegador está bloqueando o programa, por favor feche o navegador.'
    };
    for (final entry in messages.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }
  }

  Future<void> _getUserAndPassword(
    BuildContext context,
    DataNotifier dataNotifier,
  ) async {
    final user = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const InputDialog(
          title: Text('Digite sua matrícula'),
          canCancel: false,
        );
      },
    ) as String;
    final password = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const InputDialog(
          title: Text('Digite sua senha'),
          canCancel: false,
        );
      },
    ) as String;
    await dataNotifier.changeLogin(
      user: user,
      password: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, _) {
        final scrapperNotifier = watch(browserProvider.notifier);
        final scrapperState = watch(browserProvider);
        final dataNotifier = watch(dataProvider.notifier);
        final dataState = watch(dataProvider);
        if (dataState is InitialData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (dataState is UserData) {
          if (scrapperState is ScrapperIdle) {
            if (dataState.user == null || dataState.password == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    _getUserAndPassword(context, dataNotifier);
                  },
                  child: const Text('Salvar Marícula e Senha'),
                ),
              );
            }
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  scrapperNotifier.start();
                  if (dataState.firstAccess) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Ok'),
                            )
                          ],
                          content: const Text(
                              'Pode ser que você precise permitir que chrome abra o Zoom'),
                        );
                      },
                    );
                  }
                },
                child: const Text('Assistir às aulas'),
              ),
            );
          } else if (scrapperState is LaunchingScrapper) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (scrapperState is WatchingClasses) {
            final day = DateTime.now().weekday;
            var start = 0, currentClass = scrapperState.currentClass;
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
          } else if (scrapperState is ScrapperException) {
            final exception = scrapperState.exception;
            late final message = exception.toString();
            return Center(
              child: Column(
                children: [
                  const Text('Ocorreu um erro: '),
                  Card(
                    color: Theme.of(context).errorColor,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        _convertErrorMessage(message) ?? message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => scrapperNotifier.start(),
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
