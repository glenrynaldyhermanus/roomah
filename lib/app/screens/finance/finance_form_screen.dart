import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/blocs/finance/finance_bloc.dart';
import 'package:myapp/app/models/finance.dart';
import 'package:myapp/app/widgets/neumorphic_widgets.dart';

class FinanceFormScreen extends StatefulWidget {
  const FinanceFormScreen({super.key});

  @override
  State<FinanceFormScreen> createState() => _FinanceFormScreenState();
}

class _FinanceFormScreenState extends State<FinanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: const Text(
          'Add Finance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: NeumorphicButton(
          onPressed: () => context.pop(),
          depth: 6.0,
          borderRadius: 12.0,
          padding: const EdgeInsets.all(8.0),
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              NeumorphicTextField(
                controller: _nameController,
                labelText: 'Finance Name',
                prefixIcon: const Icon(Icons.account_balance_wallet),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a finance name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Amount Field
              NeumorphicTextField(
                controller: _amountController,
                labelText: 'Amount',
                prefixIcon: const Icon(Icons.attach_money),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Start Date Picker
              NeumorphicContainer(
                depth: 4.0,
                borderRadius: 16.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null && picked != _startDate) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 16),
                      Text(
                        'Start Date: ${_startDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End Date Picker
              NeumorphicContainer(
                depth: 4.0,
                borderRadius: 16.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null && picked != _endDate) {
                      setState(() {
                        _endDate = picked;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 16),
                      Text(
                        'End Date: ${_endDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              NeumorphicButton(
                onPressed: _submitForm,
                depth: 10.0,
                borderRadius: 16.0,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: const Text(
                  'Save Finance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final finance = Finance(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        startDate: _startDate,
        endDate: _endDate,
        createdAt: DateTime.now(),
      );

      context.read<FinanceBloc>().add(AddFinance(finance));
      context.pop();
    }
  }
}
