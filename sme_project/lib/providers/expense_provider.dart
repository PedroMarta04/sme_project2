import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/currency.dart';

class ExpenseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  Currency _selectedCurrency = Currency.currencies[0]; // Default USD

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Currency get selectedCurrency => _selectedCurrency;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  ExpenseProvider() {
    _loadCurrencyPreference();
  }

  Future<void> _loadCurrencyPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyCode = prefs.getString('currency') ?? 'USD';
    _selectedCurrency = Currency.findByCode(currencyCode);
    notifyListeners();
  }

  Future<void> setCurrency(Currency currency) async {
    _selectedCurrency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency.code);
    notifyListeners();
  }

  String formatAmount(double amount) {
    return '${_selectedCurrency.symbol}${amount.toStringAsFixed(2)}';
  }

  // Fetch expenses for current user
  Future<void> fetchExpenses() async {
    if (_userId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      _expenses = snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load expenses: ${e.toString()}';
      _expenses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add expense for current user
  Future<void> addExpense(Expense expense) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .add(expense.toMap());

      await fetchExpenses();
    } catch (e) {
      _error = 'Failed to add expense: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Delete expense for current user
  Future<void> deleteExpense(String id) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .doc(id)
          .delete();

      _expenses.removeWhere((expense) => expense.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete expense: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Get expenses by date range
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get total by category
  Map<String, double> getTotalByCategory() {
    Map<String, double> categoryTotals = {};
    for (var expense in _expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  // Get total spending
  double getTotalSpending() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Clear data on sign out
  void clearData() {
    _expenses = [];
    _error = null;
    notifyListeners();
  }
}