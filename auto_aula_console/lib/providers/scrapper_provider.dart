import 'dart:io';

import 'package:auto_aula_core/auto_aula_core.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:puppeteer/puppeteer.dart';
import 'package:riverpod/riverpod.dart';

import '../providers/data_provider.dart';

@immutable
abstract class ScrapperState {}

class ScrapperIdle extends ScrapperState {}

class ScrapperReady extends ScrapperState {}

class LaunchingScrapper extends ScrapperState {}

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

class ScrapperException extends ScrapperState {
  ScrapperException({
    required this.exception,
    required this.reason,
  });
  final String reason;
  final Object exception;
}

final browserProvider = StateNotifierProvider<ScrapperNotifier>(
  (ref) => ScrapperNotifier(ref.watch(dataProvider.state)),
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
  ScrapperNotifier(this._dataState) : super(ScrapperIdle());

  /// The data used by the scrapper
  final DataState _dataState;

  /// The scrapper responsible for controlling the page
  late final PageScrapper _scrapper;

  /// The browser used to
  Browser? _browser;

  /// Launches a new browser or returns an already open one
  Future<Browser> _openBrowser() {
    return puppeteer.launch(
      defaultViewport: null,
      headless: false,
      executablePath: pathToChrome,
      userDataDir:
          join(Platform.environment['appdata']!, 'auto_aula/browser_data'),
    );
  }

  /// Initializes the resources used by this [ScrapperNotifier]
  Future<void> _init() async {
    _browser = await _openBrowser();
    final page = await _browser!.newPage();
    page.defaultTimeout = const Duration(minutes: 2);
    final day = DateTime.now().weekday;
    final data = _dataState as UserData;
    _scrapper = PageScrapper(
      user: data.user!,
      password: data.password!,
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
    try {
      final hasError = state is ScrapperException;
      state = LaunchingScrapper();
      if (_browser == null) {
        await _init();
      }
      if (hasError) {
        if (_browser?.isConnected ?? false) {
          await _browser?.close();
        }
        _browser = await _openBrowser();
        await _scrapper.reset(newPage: await _browser!.newPage());
      }
      final classStream = _scrapper.watchClasses();
      await for (final classNumber in classStream) {
        state = WatchingClasses(classNumber);
      }
      await _browser!.close();
    } catch (e) {
      state = ScrapperException(exception: e, reason: '');
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _browser?.close();
    } catch (e) {
      _browser?.disconnect();
    }
    super.dispose();
  }
}
