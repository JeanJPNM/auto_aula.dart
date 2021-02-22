import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:hive/hive.dart';

import 'package:path/path.dart';

extension AutoInitHive on HiveInterface {
  void autoInit() {
    final dir = join(Platform.environment['AppData'] ?? '', 'auto_aula');
    Hive.init(dir);
  }
}
