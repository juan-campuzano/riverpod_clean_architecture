import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mf_example/mf_example.dart';
import '../../domain/implementations/fee_calculator_impl.dart';
import '../../domain/implementations/transfer_repository_impl.dart';

// Host app configuration providers
class AppConfig {
  final double transferFees;
  AppConfig({required this.transferFees});
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig(transferFees: 0.02); // 2% fee
});

final transferApiServiceProvider = Provider<String>((ref) {
  return 'https://api.mybank.com/v1';
});

class MoneyTransferDI {
  // Static list of overrides to feed into the host's ProviderScope
  static List<Override> get overrides => [
    transferRepositoryProvider.overrideWith(
      (ref) => TransferRepositoryImpl(
        apiService: ref.watch(transferApiServiceProvider),
      ),
    ),
    feeCalculatorProvider.overrideWith(
      (ref) => FeeCalculatorImpl(
        feePercentage: ref.watch(appConfigProvider).transferFees,
      ),
    ),
  ];
}
