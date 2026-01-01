import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/currency.dart';
import '../providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Currency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Consumer<ExpenseProvider>(
            builder: (context, provider, child) {
              return Column(
                children: Currency.currencies.map((currency) {
                  final isSelected = provider.selectedCurrency.code == currency.code;
                  return ListTile(
                    leading: Text(
                      currency.symbol,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(currency.name),
                    subtitle: Text(currency.code),
                    trailing: isSelected
                        ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                        : null,
                    onTap: () {
                      provider.setCurrency(currency);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Currency changed to ${currency.name}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}