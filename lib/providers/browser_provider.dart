import 'package:auto_aula/online_watcher.dart';
import 'package:auto_aula/providers/data_provider.dart';
import 'package:auto_aula/types/online_class.dart';
import 'package:meta/meta.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:riverpod/riverpod.dart';

@immutable
abstract class BrowserState {}

class BrowserIdle extends BrowserState {}

class BrowserReady extends BrowserState {}

class LaunchingBrowser extends BrowserState {}

enum ExamOption { a, b, c, d, e }

class MakingExam extends BrowserState {
  MakingExam({
    required this.end,
    required this.answers,
  });
  final DateTime end;
  final Map<int, ExamOption> answers;
}

class WatchingClasses extends BrowserState {
  WatchingClasses(this.currentClass);
  final int currentClass;
}

class BrowserException extends BrowserState {
  BrowserException({
    required this.exception,
    required this.reason,
  });
  final String reason;
  final Object exception;
}

final browserProvider = StateNotifierProvider<BrowserNotifier>(
  (ref) {
    final browserNotifier = BrowserNotifier(ref.watch(dataProvider.state));
    return browserNotifier;
  },
);

class BrowserNotifier extends StateNotifier<BrowserState> {
  BrowserNotifier(this._dataState) : super(BrowserIdle()) {
    final day = DateTime.now().weekday;
    _onlineWatcher = OnlineWatcher(
      dataState: _dataState,
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
  final DataState _dataState;
  bool _initialized = false;
  late final OnlineWatcher _onlineWatcher;
  Future<void> _init() async {
    await _onlineWatcher.init();
  }

  Future<void> start() async {
    state = LaunchingBrowser();
    if (!_initialized) await _init();
    try {
      final classStream = _onlineWatcher.start();
      await for (final classNumber in classStream) {
        state = WatchingClasses(classNumber);
      }
      await _onlineWatcher.dispose();
    } catch (e) {
      state = BrowserException(exception: e, reason: '');
    }
  }
}
