import 'package:auto_aula/util/persistent_state_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod/riverpod.dart';

@immutable
abstract class DataState {}

class InitialData extends DataState {}

class UserData extends DataState {
  UserData({
    required this.user,
    required this.password,
    this.firstAccess = true,
  });
  factory UserData._fromMap(Map<dynamic, dynamic> map) {
    return UserData(
      user: map['user'] as String?,
      password: map['password'] as String?,
      firstAccess: map['firstAccess'] as bool? ?? true,
    );
  }
  final String? user, password;
  final bool firstAccess;
  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'password': password,
      'firstAccess': false,
    };
  }
}

final dataProvider =
    StateNotifierProvider<DataNotifier, DataState>((_) => DataNotifier());

class DataNotifier extends PersistentStateNotifier<DataState> {
  DataNotifier() : super(InitialData());

  Future<void> changeLogin({String? user, String? password}) async {
    if (state is UserData) {
      final s = state as UserData;
      state = UserData(
        password: password ?? s.password,
        user: user ?? s.user,
        firstAccess: false,
      );
    } else {
      state = UserData(
        password: password ?? '',
        user: user ?? '',
        firstAccess: false,
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
