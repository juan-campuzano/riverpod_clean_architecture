import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mf_example/mf_example.dart';

class MockTransferRepository implements TransferRepository {
  bool transferCalled = false;
  @override
  Future<void> transferMoney({
    required String fromAccount,
    required String toAccount,
    required double amount,
  }) async {
    transferCalled = true;
  }
}

class MockFeeCalculator implements FeeCalculator {
  @override
  double calculateFee(double amount) => amount * 0.05;
}

void main() {
  testWidgets('TransferPage renders and triggers transfer with DI overrides', (WidgetTester tester) async {
    final mockRepo = MockTransferRepository();
    final mockCalc = MockFeeCalculator();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transferRepositoryProvider.overrideWith((ref) => mockRepo),
          feeCalculatorProvider.overrideWith((ref) => mockCalc),
        ],
        child: const MaterialApp(
          home: TransferPage(),
        ),
      ),
    );

    // Verify title is rendered
    expect(find.text('Money Transfer Micro-Frontend'), findsOneWidget);
    
    // Calculated fee for initial amount (100.00) under MockFeeCalculator should be 5.00
    expect(find.text('\$5.00'), findsOneWidget);

    // Tap transfer button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify repository call and success UI message
    expect(mockRepo.transferCalled, isTrue);
    expect(find.textContaining('Transfer of \$100.00'), findsOneWidget);
  });
}
