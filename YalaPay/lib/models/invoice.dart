class Invoice {
  String id;
  String customerId;
  String customerName;
  double amount;
  String invoiceDate;
  String dueDate;

  Invoice({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.invoiceDate,
    required this.dueDate,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      amount: json['amount'],
      invoiceDate: json['invoiceDate'],
      dueDate: json['dueDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'amount': amount,
      'invoiceDate': invoiceDate,
      'dueDate': dueDate,
    };
  }
}
