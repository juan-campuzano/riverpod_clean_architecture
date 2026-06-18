// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_transfer_contracts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transferRepository)
final transferRepositoryProvider = TransferRepositoryProvider._();

final class TransferRepositoryProvider
    extends
        $FunctionalProvider<
          TransferRepository,
          TransferRepository,
          TransferRepository
        >
    with $Provider<TransferRepository> {
  TransferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransferRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransferRepository create(Ref ref) {
    return transferRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransferRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransferRepository>(value),
    );
  }
}

String _$transferRepositoryHash() =>
    r'22a1e8d42bf0d39bd69d3fb3e488fee7e850894b';

@ProviderFor(feeCalculator)
final feeCalculatorProvider = FeeCalculatorProvider._();

final class FeeCalculatorProvider
    extends $FunctionalProvider<FeeCalculator, FeeCalculator, FeeCalculator>
    with $Provider<FeeCalculator> {
  FeeCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feeCalculatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feeCalculatorHash();

  @$internal
  @override
  $ProviderElement<FeeCalculator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeeCalculator create(Ref ref) {
    return feeCalculator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeeCalculator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeeCalculator>(value),
    );
  }
}

String _$feeCalculatorHash() => r'68a163f41372fd2e2fb1393f51a1217b49d3427c';
