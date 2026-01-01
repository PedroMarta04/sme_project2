import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'category': category,
    'description': description,
    'date': Timestamp.fromDate(date),
  };

  // Create from Firestore document
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'Other',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // For JSON compatibility (if needed)
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'description': description,
    'date': date.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    title: json['title'],
    amount: json['amount'],
    category: json['category'],
    description: json['description'],
    date: DateTime.parse(json['date']),
  );
}