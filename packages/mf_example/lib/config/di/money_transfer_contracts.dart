import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/contracts/fee_calculator.dart';
import '../../domain/contracts/transfer_repository.dart';

part 'money_transfer_contracts.g.dart';

@Riverpod(keepAlive: true)
TransferRepository transferRepository(Ref ref) {
  throw UnimplementedError(
    'transferRepositoryProvider must be overridden by the host app.',
  );
}

@Riverpod(keepAlive: true)
FeeCalculator feeCalculator(Ref ref) {
  throw UnimplementedError(
    'feeCalculatorProvider must be overridden by the host app.',
  );
}
