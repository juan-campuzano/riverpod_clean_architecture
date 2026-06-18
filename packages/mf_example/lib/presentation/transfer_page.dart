import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/di/money_transfer_contracts.dart';

class TransferPage extends ConsumerStatefulWidget {
  const TransferPage({super.key});

  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends ConsumerState<TransferPage> {
  final _fromController = TextEditingController(text: 'ACC-12345');
  final _toController = TextEditingController(text: 'ACC-67890');
  final _amountController = TextEditingController(text: '100.00');

  String? _statusMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _executeTransfer() async {
    final from = _fromController.text;
    final to = _toController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount <= 0) {
      setState(() {
        _statusMessage = 'Please enter a valid amount greater than zero.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Consume the abstract repository provided via DI
      final repository = ref.read(transferRepositoryProvider);
      
      await repository.transferMoney(
        fromAccount: from,
        toAccount: to,
        amount: amount,
      );

      setState(() {
        _statusMessage = 'Transfer of \$${amount.toStringAsFixed(2)} from $from to $to completed successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Transfer failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch/Read the abstract fee calculator provided via DI
    final feeCalculator = ref.watch(feeCalculatorProvider);
    final currentAmount = double.tryParse(_amountController.text) ?? 0.0;
    final fee = feeCalculator.calculateFee(currentAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Transfer Micro-Frontend'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _fromController,
              decoration: const InputDecoration(
                labelText: 'Source Account',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'Destination Account',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (\$)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                // Rebuild to recalculate fee dynamically
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Calculated Transfer Fee:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${fee.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _executeTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Transfer Money'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 24),
              Text(
                _statusMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _statusMessage!.contains('failed') || _statusMessage!.contains('valid')
                      ? Colors.red
                      : Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
