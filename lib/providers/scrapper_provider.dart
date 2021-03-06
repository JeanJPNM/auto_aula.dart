import 'dart:io';

import 'package:auto_aula/page_scrapper.dart';
import 'package:auto_aula/providers/data_provider.dart';
import 'package:auto_aula/types/online_class.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:riverpod/riverpod.dart';
import 'package:desktoasts/desktoasts.dart';

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

final browserProvider = StateNotifierProvider<ScrapperNotifier, ScrapperState>(
  (ref) {
    final data = ref.watch(dataProvider);
    final browserNotifier = ScrapperNotifier(data);
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
  ScrapperNotifier(this._dataState) : super(ScrapperIdle());

  static ToastService? toastService;

  /// The data used by the scrapper
  final DataState _dataState;

  /// The scrapper responsible for controlling the page
  PageScrapper? _scrapper;

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
    if (_browser != null && _scrapper != null) return;
    _browser = await _openBrowser();
    final page = await _browser!.newPage();
    final data = _dataState;
    page.defaultTimeout =
        data is UserData ? data.timeoutDuration : const Duration(minutes: 2);
    final day = DateTime.now().weekday;
    _scrapper = PageScrapper(
      dataState: data,
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
      await _init();
      final hasError = state is ScrapperException;
      state = LaunchingScrapper();
      if (hasError) {
        if (_browser?.isConnected ?? false) {
          _browser?.close();
        }
        _browser = await _openBrowser();
        await _scrapper!.reset(newPage: await _browser!.newPage());
      }
      final classStream = _scrapper!.watchClasses();
      await for (final classNumber in classStream) {
        state = WatchingClasses(classNumber);
      }
      await _browser!.close();
    } catch (e) {
      toastService ??= ToastService(
        appName: 'Auto Aula',
        companyName: 'JPNM',
        productName: 'com.jeanjpnm.auto_aula',
      );
      toastService?.show(Toast(
        type: ToastType.text01,
        title: 'Erro na auto aula, por favor reinicie o programa',
      ));
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
