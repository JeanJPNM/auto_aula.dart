// @dart=2.10
import 'dart:io';

import 'providers/theme_provider.dart';
import 'screen_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = join(Platform.environment['AppData'] ?? '', 'auto_aula');
  Hive.init(dir);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider.state);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      home: ScreenHost(),
    );
  }
}
