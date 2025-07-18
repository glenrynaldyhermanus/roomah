import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: const Text('To-Do List'),
      ),
      body: Center(
        child: NeumorphicIcon(
          PhosphorIcons.checkSquare(),
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
