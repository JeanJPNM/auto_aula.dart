// @dart=2.10
import 'dart:io';

import 'package:auto_aula/providers/theme_provider.dart';
import 'package:auto_aula/screens/home.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: import_of_legacy_library_into_null_safe
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
  // ignore: type_annotate_public_apis
  Widget build(BuildContext context, watch) {
    final theme = watch(themeProvider.state);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      home: Home(),
    );
  }
}
