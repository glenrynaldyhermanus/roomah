import 'package:flutter/material.dart';
import 'package:myapp/app/widgets/neumorphic_widgets.dart';

class UiDemoScreen extends StatefulWidget {
  const UiDemoScreen({super.key});

  @override
  State<UiDemoScreen> createState() => _UiDemoScreenState();
}

class _UiDemoScreenState extends State<UiDemoScreen> {
  int toggleIndex = 0;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: const Text('UI Neumorphic Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Neumorphic Button',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            NeumorphicContainer(
              isPressed: true,
              borderRadius: 8,
              padding: const EdgeInsets.all(24),
              child: const Center(child: Text('Outer')),
            ),
            NeumorphicContainer(
              isPressed: false,
              borderRadius: 8,
              padding: const EdgeInsets.all(24),
              child: const Center(child: Text('Outer')),
            ),
            Row(
              children: [
                NeumorphicButton(
                  onPressed: () {},
                  child: const Icon(Icons.favorite, color: Colors.purple),
                  depth: 8,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                ),
                const SizedBox(width: 16),
                NeumorphicButton(
                  onPressed: () {},
                  child: const Text('Follow'),
                  depth: 8,
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Neumorphic Card',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            NeumorphicCard(
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 12),
                  const Text('Ini contoh Neumorphic Card'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Neumorphic TextField',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            NeumorphicTextField(
              controller: _textController,
              labelText: 'Input sesuatu...',
              prefixIcon: const Icon(Icons.search),
            ),
            const SizedBox(height: 24),
            const Text(
              'Neumorphic Toggle',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            NeumorphicToggle(
              selectedIndex: toggleIndex,
              onChanged: (i) => setState(() => toggleIndex = i),
              options: const ['Tab 1', 'Tab 2', 'Tab 3'],
              height: 48,
              borderRadius: 16,
            ),
            const SizedBox(height: 24),
            const Text(
              'Neumorphic Container (Inner/Outer)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NeumorphicContainer(
                    isPressed: false,
                    borderRadius: 16,
                    padding: const EdgeInsets.all(24),
                    child: const Center(child: Text('Outer')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NeumorphicContainer(
                    isPressed: true,
                    borderRadius: 16,
                    padding: const EdgeInsets.all(24),
                    child: const Center(child: Text('Inner')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Neumorphic Quick Action',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {},
                    child: Column(
                      children: const [
                        Icon(Icons.add_task, color: Colors.green, size: 32),
                        SizedBox(height: 8),
                        Text('Tambah Todo'),
                      ],
                    ),
                    depth: 8,
                    borderRadius: 12,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {},
                    child: Column(
                      children: const [
                        Icon(Icons.add_chart, color: Colors.blue, size: 32),
                        SizedBox(height: 8),
                        Text('Catat Keuangan'),
                      ],
                    ),
                    depth: 8,
                    borderRadius: 12,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
