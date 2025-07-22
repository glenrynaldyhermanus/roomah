import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:myapp/app/widgets/neuma_widgets.dart';

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
    return NeumorphicBackground(
      child: Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        appBar: NeumorphicAppBar(
          title: const Text('UI Neumorphic Demo'),
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

              Row(
                children: [
                  NeumaButton(
                    onPressed: () {},
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.favorite, color: Colors.purple),
                  ),
                  const SizedBox(width: 16),
                  NeumaButton(
                    onPressed: () {},
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: const Text('Follow'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Neumorphic Card',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              NeumaCard(
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
                'NeumaTextField (Default)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              NeumaTextField(
                controller: _textController,
                hintText: 'Demo Input',
                icon: Icons.input,
              ),
              const SizedBox(height: 16),
              const Text(
                'NeumaTextField (Compact)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              NeumaTextField.compact(
                controller: _textController,
                hintText: 'Compact Input',
                icon: Icons.edit,
              ),
              const SizedBox(height: 24),
              const Text(
                'NeumaToggle (Custom Toggle)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              NeumaToggle(
                selectedIndex: toggleIndex,
                options: const ['Tab 1', 'Tab 2', 'Tab 3'],
                onChanged: (index) => setState(() => toggleIndex = index),
                height: 48,
                activeColor: Colors.blue[600],
                activeTextColor: Colors.white,
                inactiveTextColor: Colors.grey[700],
              ),
              const SizedBox(height: 16),
              const Text(
                'NeumaToggle Compact',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              NeumaToggle(
                selectedIndex: toggleIndex,
                options: const ['Option A', 'Option B'],
                onChanged: (index) => setState(() => toggleIndex = index),
                height: 40,
                activeColor: Colors.purple[600],
                activeTextColor: Colors.white,
                inactiveTextColor: Colors.grey[700],
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
                    child: NeumaCard(
                      child: const Center(child: Text('Outer')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeumaCard(
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
                    child: NeumaButton(
                      onPressed: () {},
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: const [
                          Icon(Icons.add_task, color: Colors.green, size: 32),
                          SizedBox(height: 8),
                          Text('Tambah Todo'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeumaButton(
                      onPressed: () {},
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: const [
                          Icon(Icons.add_chart, color: Colors.blue, size: 32),
                          SizedBox(height: 8),
                          Text('Catat Keuangan'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
