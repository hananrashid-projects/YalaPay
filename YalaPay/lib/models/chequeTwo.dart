// cheque.dart
class ChequeTwo {
  final int chequeNo;
  final double amount;
  final String drawer;
  final String bankName;
  String status; // Mutable for status updates
  final DateTime receivedDate;
  final DateTime dueDate;
  final String chequeImageUri;

  ChequeTwo({
    required this.chequeNo,
    required this.amount,
    required this.drawer,
    required this.bankName,
    required this.status,
    required this.receivedDate,
    required this.dueDate,
    required this.chequeImageUri,
  });

  factory ChequeTwo.fromJson(Map<String, dynamic> json) {
    return ChequeTwo(
      chequeNo: json['chequeNo'],
      amount: json['amount'],
      drawer: json['drawer'],
      bankName: json['bankName'],
      status: json['status'],
      receivedDate: DateTime.parse(json['receivedDate']),
      dueDate: DateTime.parse(json['dueDate']),
      chequeImageUri: json['chequeImageUri'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chequeNo': chequeNo,
      'amount': amount,
      'drawer': drawer,
      'bankName': bankName,
      'status': status,
      'receivedDate': receivedDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'chequeImageUri': chequeImageUri,
    };
  }
}
