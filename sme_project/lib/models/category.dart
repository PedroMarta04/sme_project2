import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  static List<ExpenseCategory> categories = [
    ExpenseCategory(name: 'Food', icon: Icons.restaurant, color: Colors.orange),
    ExpenseCategory(name: 'Transport', icon: Icons.directions_car, color: Colors.blue),
    ExpenseCategory(name: 'Entertainment', icon: Icons.movie, color: Colors.purple),
    ExpenseCategory(name: 'Shopping', icon: Icons.shopping_bag, color: Colors.pink),
    ExpenseCategory(name: 'Bills', icon: Icons.receipt, color: Colors.red),
    ExpenseCategory(name: 'Health', icon: Icons.health_and_safety, color: Colors.green),
    ExpenseCategory(name: 'Education', icon: Icons.school, color: Colors.indigo),
    ExpenseCategory(name: 'Other', icon: Icons.more_horiz, color: Colors.grey),
  ];
}