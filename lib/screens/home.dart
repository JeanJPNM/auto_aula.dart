import 'package:auto_aula/providers/browser_provider.dart';
import 'package:auto_aula/providers/data_provider.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Aula'),
      ),
      body: _OnlineProgress(),
    );
  }
}

class _OnlineProgress extends StatefulWidget {
  _OnlineProgress();
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
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (dataState is UserData) {
          if (dataState.user == null || dataState.password == null) {
            return Center(
              child: Column(
                children: [
                  TextField(
                    controller: userController,
                    decoration: InputDecoration(labelText: 'Matrícula'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Senha'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Pronto'),
                    onPressed: () {
                      dataNotifier.changeLogin(
                        user: userController.text,
                        password: passwordController.text,
                      );
                    },
                  )
                ],
              ),
            );
          }
          if (browserState is BrowserIdle) {
            return Center(
              child: OutlinedButton(
                child: Text('Assistir às aulas'),
                onPressed: () {
                  browserNotifier.start();
                },
              ),
            );
          } else if (browserState is LaunchingBrowser) {
            return Center(
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
                          ? Icon(Icons.done)
                          : CircularProgressIndicator(),
                    )
                ],
              ),
            );
          } else if (browserState is BrowserException) {
            return Center(
              child: Column(
                children: [
                  Text('Ocorreu um erro: '),
                  Text(browserState.exception.toString()),
                  TextButton(
                    onPressed: () => browserNotifier.start(),
                    child: Text('Tentar novamente'),
                  )
                ],
              ),
            );
          }
        }
        return Center(child: Text('Erro'));
      },
    );
  }
}
