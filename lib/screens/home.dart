import 'package:auto_aula/providers/scrapper_provider.dart';
import 'package:auto_aula/providers/data_provider.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Aula'),
      ),
      body: const _OnlineProgress(),
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
          if (browserState is BrowserIdle) {
            return Center(
              child: OutlinedButton(
                onPressed: () {
                  browserNotifier.start();
                },
                child: const Text('Assistir às aulas'),
              ),
            );
          } else if (browserState is LaunchingBrowser) {
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
          } else if (browserState is BrowserException) {
            return Center(
              child: Column(
                children: [
                  const Text('Ocorreu um erro: '),
                  Text(browserState.exception.toString()),
                  TextButton(
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
