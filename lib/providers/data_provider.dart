import 'package:auto_aula/util/persistent_state_notifier.dart';
import 'package:flutter/cupertino.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:riverpod/riverpod.dart';

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

final dataProvider = StateNotifierProvider((_) => DataNotifier());

class DataNotifier extends PersistentStateNotifier<DataState> {
  DataNotifier() : super(InitialData());

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
  }

  @override
  DataState fromMap(Map<String, dynamic> map) {
    return UserData._fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(DataState state) {
    if (state is UserData) {
      return state.toMap();
    } else {
      return {};
    }
  }
}
