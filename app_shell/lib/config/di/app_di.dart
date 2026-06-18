import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_di.dart';
import 'money_transfer_di.dart';
import 'profile_di.dart';

class AppDI {
  static List<Override> get overrides => [
    ...MoneyTransferDI.overrides,
    ...AuthDI.overrides,
    ...ProfileDI.overrides,
  ];
}
