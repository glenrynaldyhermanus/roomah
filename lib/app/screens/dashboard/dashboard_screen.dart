import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            NeumorphicIcon(
              PhosphorIcons.house(),
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to your Household App!',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
