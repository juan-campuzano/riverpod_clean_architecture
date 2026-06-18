abstract class TransferRepository {
  Future<void> transferMoney({
    required String fromAccount,
    required String toAccount,
    required double amount,
  });
}
