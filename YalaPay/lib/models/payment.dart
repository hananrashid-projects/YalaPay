class Payment {
  final String id;
  final String invoiceNo;
  final double amount;
  final String paymentDate;
  final String paymentMode;
  final int? chequeNo;
  Payment({
    required this.id,
    required this.invoiceNo,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    this.chequeNo,
  });
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      invoiceNo: json['invoiceNo'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: json['paymentDate'] as String,
      paymentMode: json['paymentMode'] as String,
      chequeNo: json['chequeNo'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNo': invoiceNo,
      'amount': amount,
      'paymentDate': paymentDate,
      'paymentMode': paymentMode,
      'chequeNo': chequeNo,
    };
  }
}
