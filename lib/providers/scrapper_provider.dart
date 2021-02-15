import 'dart:io';

import 'package:auto_aula/page_scrapper.dart';
import 'package:auto_aula/providers/data_provider.dart';
import 'package:auto_aula/types/online_class.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:puppeteer/puppeteer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:riverpod/riverpod.dart';

@immutable
abstract class ScrapperState {}

class BrowserIdle extends ScrapperState {}

class BrowserReady extends ScrapperState {}

class LaunchingBrowser extends ScrapperState {}

enum ExamOption { a, b, c, d, e }

class MakingExam extends ScrapperState {
  MakingExam({
    required this.end,
    required this.answers,
  });
  final DateTime end;
  final Map<int, ExamOption> answers;
}

class WatchingClasses extends ScrapperState {
  WatchingClasses(this.currentClass);
  final int currentClass;
}

class BrowserException extends ScrapperState {
  BrowserException({
    required this.exception,
    required this.reason,
  });
  final String reason;
  final Object exception;
}

final browserProvider = StateNotifierProvider<ScrapperNotifier>(
  (ref) {
    final browserNotifier = ScrapperNotifier(ref.watch(dataProvider.state));
    return browserNotifier;
  },
);
String? get pathToChrome {
  String env(String variable) =>
      Platform.environment[variable] ?? r'c:\program files (x86)';
  final paths = [
    join(env('ProgramFiles(x86)'), r'Google\Chrome\Application\chrome.exe'),
    join(env('ProgramFiles'), r'Google\Chrome\Application\chrome.exe'),
    join(env('LocalAppData'), r'Google\Chrome\Application\chrome.exe'),
  ];
  String? result;
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) result = file.path;
  }
  return result;
}

class ScrapperNotifier extends StateNotifier<ScrapperState> {
  ScrapperNotifier(this._dataState) : super(BrowserIdle());
  final DataState _dataState;
  bool _initialized = false;
  late final PageScrapper _pageScrapper;
  Browser? _browser;
  Future<Browser> _createBrowser() {
    return puppeteer.launch(
      defaultViewport: null,
      headless: false,
      executablePath: pathToChrome,
      userDataDir:
          join(Platform.environment['appdata']!, 'auto_aula/browser_data'),
    );
  }

  Future<void> _init() async {
    await _browser?.close();
    _browser = await _createBrowser();
    final page = await _browser!.newPage();
    page.defaultTimeout = const Duration(minutes: 2);
    final day = DateTime.now().weekday;
    _pageScrapper = PageScrapper(
      dataState: _dataState,
      page: page,
      onlineClasses: [
        if (day != DateTime.tuesday && day != DateTime.thursday)
          OnlineClass(7, 10),
        OnlineClass(8, 5),
        OnlineClass(9, 0),
        OnlineClass(10, 10),
        OnlineClass(11, 5),
        OnlineClass(12, 0),
      ],
    );
  }

  Future<void> start() async {
    final hasError = state is BrowserException;
    state = LaunchingBrowser();
    if (!_initialized) {
      await _init();
      _initialized = true;
    }
    if (hasError) {
      await _browser!.close();
      _browser = await _createBrowser();
      await _pageScrapper.reset(newPage: await _browser!.newPage());
    }
    try {
      final classStream = _pageScrapper.watchClasses();
      await for (final classNumber in classStream) {
        state = WatchingClasses(classNumber);
      }
    } catch (e) {
      state = BrowserException(exception: e, reason: '');
    }
  }

  @override
  Future<void> dispose() async {
    await _browser?.close();
    super.dispose();
  }
}
