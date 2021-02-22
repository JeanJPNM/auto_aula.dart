import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:hive/hive.dart';

/// A simple solution to persist a [StateNotifier], inspired by `HydratedBloc`
abstract class PersistentStateNotifier<T> extends StateNotifier<T> {
  PersistentStateNotifier(T state) : super(state) {
    _load();
  }

  static Box? _box;
  static Future<void> _openBox() async {
    _box ??= await Hive.openBox('persistent_state_notifiers');
  }

  /// The id used to identify this [PersistentStateNotifier].
  ///
  /// Override it if you want to have multiple instances of this [PersistentStateNotifier]
  String get id => '';

  /// The token used to identify this [PersistentStateNotifier] on the database
  String get databaseToken => '$runtimeType$id';

  Future<void> _load() async {
    await _openBox();
    final data = _box!.get(databaseToken, defaultValue: {}) as Map;
    state = fromMap(data.cast<String, dynamic>());
  }

  /// Coverts [state] to a [Map] to save it in the database
  @protected
  Map<String, dynamic> toMap(T state);

  /// Creates an instance of [T] from [map]
  ///
  /// If this is the first time [PersistentStateNotifier] load data from memory,
  /// [map] will be an empty map
  @protected
  T fromMap(Map<String, dynamic> map);

  @override
  set state(T value) {
    _box!.put(databaseToken, toMap(value)).then((_) {}, onError: onError);
    super.state = value;
  }
}
