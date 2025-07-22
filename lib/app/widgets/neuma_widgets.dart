import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class NeumaTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final EdgeInsets? padding;

  const NeumaTextField({
    super.key,
    this.controller,
    this.hintText,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.padding,
  });

  /// Constructor untuk text field yang lebih compact
  const NeumaTextField.compact({
    super.key,
    this.controller,
    this.hintText,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  }) : padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 2);

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -4,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.all(Radius.circular(30)),
        ),
      ),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 16),
          prefixIcon:
              icon != null
                  ? Icon(icon, color: const Color(0xFFB0B0B0), size: 18)
                  : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}

class NeumaButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;
  final double depth;
  final EdgeInsets padding;

  const NeumaButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 30,
    this.depth = 8,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: onPressed,
      style: NeumorphicStyle(
        depth: depth,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}

class NeumaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double borderRadius;
  final double depth;

  const NeumaCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.depth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: depth,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
      margin: margin,
      padding: padding,
      child: child,
    );
  }
}

/// Custom Neumorphic Toggle Widget
///
/// A beautiful toggle widget with neumorphic design that provides smooth animations
/// and clear visual feedback for selected states.
///
/// Example usage:
/// ```dart
/// NeumaToggle(
///   selectedIndex: _selectedIndex,
///   options: const ['Option 1', 'Option 2', 'Option 3'],
///   onChanged: (index) => setState(() => _selectedIndex = index),
///   height: 50,
///   activeColor: Colors.blue[600],
///   activeTextColor: Colors.white,
///   inactiveTextColor: Colors.grey[700],
/// )
/// ```
class NeumaToggle extends StatelessWidget {
  /// The currently selected option index
  final int selectedIndex;

  /// List of option strings to display
  final List<String> options;

  /// Callback function when selection changes
  final Function(int) onChanged;

  /// Height of the toggle widget (default: 50)
  final double height;

  /// Color of the active/selected thumb (default: Colors.blue[600])
  final Color? activeColor;

  /// Color of the inactive background (default: theme.baseColor)
  final Color? inactiveColor;

  /// Color of the active text (default: Colors.white)
  final Color? activeTextColor;

  /// Color of the inactive text (default: Colors.grey[700])
  final Color? inactiveTextColor;

  const NeumaToggle({
    super.key,
    required this.selectedIndex,
    required this.options,
    required this.onChanged,
    this.height = 50,
    this.activeColor,
    this.inactiveColor,
    this.activeTextColor,
    this.inactiveTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeTextColor = this.activeTextColor ?? Colors.white;
    final inactiveTextColor = this.inactiveTextColor ?? Colors.grey[700]!;

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 4,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(height / 2),
        ),
      ),
      child: SizedBox(
        height: height,
        child: Row(
          children:
              options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = index == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          depth: isSelected ? -4 : 0,
                          // color: isSelected ? activeColor : null, // Hapus pewarnaan solid
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(height / 2),
                          ),
                        ),
                        child: Container(
                          height: height,
                          alignment: Alignment.center,
                          child: Text(
                            option,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: inactiveTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
