// @dart=2.10
import 'dart:io';

import 'package:auto_aula_console/auto_aula_console.dart';
import 'package:hive/hive.dart';
import 'package:riverpod/riverpod.dart';

Future<void> main() async {
  try {
    await run();
  } catch (e) {
    stdout.write(e);
  }
}

Future<void> run() async {
  Hive.autoInit();
  final container = ProviderContainer();
  final dataNotifier = container.read(dataProvider);
  container.read(browserProvider);
  // workaround for concurrent access
  await Future.delayed(const Duration(seconds: 2));
  dataNotifier.addListener((state) {
    final data = container.read(dataProvider.state);
    if (data is InitialData) {
      return;
    } else if (data is UserData) {
      String user, password;
      if (data.user == null || data.password == null) {
        stdout.write('Digite sua matrícula: ');
        user = stdin.readLineSync();
        stdout.write('Digite sua senha: ');
        password = stdin.readLineSync();
        dataNotifier.changeLogin(
          user: user,
          password: password,
        );
        return;
      }
      Process.runSync('cls', [], runInShell: true);
      container.read(browserProvider).addListener((state) {
        if (state is WatchingClasses) {
          stdout.writeln('Assistindo à aula ${state.currentClass + 1}');
        }
      }, fireImmediately: false);
      stdout.writeAll([
        '[0] Assistir às aulas',
        '[1] Trocar matrícula',
        '[2] Trocar senha',
      ], '\n');
      stdout.writeln();
      final option = int.parse(stdin.readLineSync() ?? '0');
      switch (option) {
        case 0:
          container.read(browserProvider).start();
          break;
        case 1:
          stdout.write('Digite sua nova matrícula: ');
          dataNotifier.changeLogin(user: stdin.readLineSync());
          break;
        case 2:
          stdout.write('Digite sua nova senha: ');
          dataNotifier.changeLogin(user: stdin.readLineSync());
          break;
        default:
          stdout.writeln('Opção inválida');
          break;
      }
    }
  });
}
