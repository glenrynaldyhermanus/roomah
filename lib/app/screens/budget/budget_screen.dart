import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: const Text('Budget Manager'),
      ),
      body: Center(
        child: NeumorphicIcon(
          PhosphorIcons.wallet(),
          size: 100,
        ),
      ),
      floatingActionButton: NeumorphicFloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
