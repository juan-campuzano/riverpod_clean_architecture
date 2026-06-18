import 'package:mf_example/mf_example.dart';

class FeeCalculatorImpl implements FeeCalculator {
  final double feePercentage;

  FeeCalculatorImpl({required this.feePercentage});

  @override
  double calculateFee(double amount) {
    // Basic calculation representing fee logic
    return amount * feePercentage;
  }
}
