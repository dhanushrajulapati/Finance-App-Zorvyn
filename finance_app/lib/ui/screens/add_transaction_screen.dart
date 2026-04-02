import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'expense';
  DateTime _date = DateTime.now();

  final _categories = [
    'Food',
    'Utilities',
    'Transport',
    'Entertainment',
    'Salary',
    'Shopping',
    'Other',
  ];

  bool get _isEditing => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transactionToEdit!;
      _amountController.text = t.amount.toString();
      if (!_categories.contains(t.category)) {
        _categories.add(t.category);
      }
      _categoryController.text = t.category;
      _notesController.text = t.notes ?? '';
      _type = t.type;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              onPressed: () {
                context.read<FinanceProvider>().deleteTransaction(
                  widget.transactionToEdit!.id,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted')),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeToggle(),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText:
                    '${context.watch<SettingsProvider>().currencySymbol} ',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue:
                  _categories.contains(_categoryController.text) &&
                      _categoryController.text.isNotEmpty
                  ? _categoryController.text
                  : _categories.first,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  _categoryController.text = val;
                }
              },
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _date = pickedDate;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(DateFormat('MMM d, yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount'),
                      ),
                    );
                    return;
                  }

                  final category = _categoryController.text.isNotEmpty
                      ? _categoryController.text
                      : _categories.first;

                  if (_isEditing) {
                    context.read<FinanceProvider>().updateTransaction(
                      id: widget.transactionToEdit!.id,
                      amount: amount,
                      type: _type,
                      category: category,
                      date: _date,
                      notes: _notesController.text,
                    );
                  } else {
                    context.read<FinanceProvider>().addTransaction(
                      amount: amount,
                      type: _type,
                      category: category,
                      date: _date,
                      notes: _notesController.text,
                    );
                  }

                  Navigator.pop(context);
                },
                child: Text(_isEditing ? 'Save Changes' : 'Save Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton('Expense', 'expense', AppColors.expense),
          ),
          Expanded(
            child: _buildToggleButton('Income', 'income', AppColors.income),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value, Color color) {
    final isSelected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius - 4),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
