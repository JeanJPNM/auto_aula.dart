import 'package:flutter/cupertino.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:riverpod/riverpod.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:hive/hive.dart';

@immutable
abstract class DataState {}

class InitialData extends DataState {}

class UserData extends DataState {
  UserData({required this.user, required this.password});
  factory UserData._fromMap(Map<dynamic, dynamic> map) {
    return UserData(
      user: map['user'] as String?,
      password: map['password'] as String?,
    );
  }
  final String? user, password;
  Map<String, String?> toMap() {
    return {'user': user, 'password': password};
  }
}

final dataProvider = StateNotifierProvider<DataNotifier>((_) {
  final notifier = DataNotifier();
  notifier.init();
  return notifier;
});

class DataNotifier extends StateNotifier<DataState> {
  DataNotifier() : super(InitialData());
  late Box _box;
  Future<void> init() async {
    _box = await Hive.openBox('userData');
    state = UserData._fromMap(_box.toMap());
  }

  Future<void> changeLogin({String? user, String? password}) async {
    if (state is UserData) {
      final s = state as UserData;
      state = UserData(
        password: password ?? s.password,
        user: user ?? s.user,
      );
    } else {
      state = UserData(
        password: password ?? '',
        user: user ?? '',
      );
    }
    assert(state is UserData);
    await _box.putAll((state as UserData).toMap());
  }
}
