import 'package:flutter/cupertino.dart';
import 'package:riverpod/riverpod.dart';
import 'package:hive/hive.dart';

@immutable
abstract class DataState {}

class InitialData extends DataState {}

class UserData extends DataState {
  UserData({this.user, this.password});
  factory UserData._fromMap(Map<dynamic, dynamic> map) {
    return UserData(
      user: map['user'],
      password: map['password'],
    );
  }
  final String user, password;
  Map<String, String> toMap() {
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
  Box _box;
  Future<void> init() async {
    _box = await Hive.openBox('userData');
    state = UserData._fromMap(_box.toMap());
  }

  Future<void> changeLogin({String user, String password}) async {
    if (state is UserData) {
      UserData s = state;
      state = UserData(
        password: password ?? s.password,
        user: user ?? s.user,
      );
    } else {
      state = UserData(
        password: password,
        user: user,
      );
    }
    assert(state is UserData);
    await _box.putAll((state as UserData).toMap());
  }
}
