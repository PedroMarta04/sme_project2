import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          // Check if there are no expenses
          if (provider.expenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No data to display',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add expenses to see statistics',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // If there are expenses, show statistics
          final categoryTotals = provider.getTotalByCategory();
          final totalSpending = provider.getTotalSpending();

          // Sort categories by amount
          final sortedCategories = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Spending Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Spending',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.formatAmount(totalSpending),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.expenses.length} transactions',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Spending Chart Section
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Spending by Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Simple Bar Chart - FIXED
                Container(
                  height: 250, // Increased total height
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: sortedCategories.map((entry) {
                      final categoryName = entry.key;
                      final amount = entry.value;
                      final percentage = (amount / totalSpending);

                      final category = ExpenseCategory.categories.firstWhere(
                            (cat) => cat.name == categoryName,
                        orElse: () => ExpenseCategory.categories.last,
                      );

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min, // FIXED: Don't expand
                            children: [
                              // Amount label
                              SizedBox(
                                height: 30, // Fixed height for label
                                child: Text(
                                  provider.formatAmount(amount),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Bar - FIXED: Use Flexible instead of fixed height
                              Flexible(
                                child: FractionallySizedBox(
                                  heightFactor: percentage,
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: double.infinity,
                                    constraints: const BoxConstraints(
                                      minHeight: 20, // Minimum visible bar
                                      maxHeight: 150, // Maximum bar height
                                    ),
                                    decoration: BoxDecoration(
                                      color: category.color,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Category icon and label
                              Icon(category.icon, size: 20, color: category.color),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 30, // Fixed height for label
                                child: Text(
                                  categoryName,
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Category Breakdown
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Category Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedCategories.length,
                  itemBuilder: (context, index) {
                    final entry = sortedCategories[index];
                    final categoryName = entry.key;
                    final amount = entry.value;
                    final percentage = (amount / totalSpending * 100);

                    final category = ExpenseCategory.categories.firstWhere(
                          (cat) => cat.name == categoryName,
                      orElse: () => ExpenseCategory.categories.last,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: category.color.withOpacity(0.2),
                                  child: Icon(category.icon, color: category.color),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        categoryName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}% of total',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  provider.formatAmount(amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: category.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  category.color,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}