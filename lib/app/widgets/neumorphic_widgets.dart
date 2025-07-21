import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double depth;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isPressed;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.depth = 8.0,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFFE0E5EC);
    final lightColor = _adjustColor(bgColor, 0.15);
    final darkColor = _adjustColor(bgColor, -0.15);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: bgColor,
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: darkColor.withAlpha((255 * 0.5).round()),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: lightColor.withAlpha((255 * 0.5).round()),
                  offset: const Offset(-3, -3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ]
            : [
                BoxShadow(
                  color: darkColor.withAlpha((255 * 0.6).round()),
                  offset: Offset(depth, depth),
                  blurRadius: depth * 1.5,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: lightColor.withAlpha((255 * 0.6).round()),
                  offset: Offset(-depth, -depth),
                  blurRadius: depth * 1.5,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPressed
                ? [darkColor, bgColor]
                : [lightColor, bgColor],
          ),
        ),
        child: child,
      ),
    );
  }

  Color _adjustColor(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      (color.red + (amount * 255)).clamp(0, 255).round(),
      (color.green + (amount * 255)).clamp(0, 255).round(),
      (color.blue + (amount * 255)).clamp(0, 255).round(),
    );
  }
}

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double depth;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.depth = 8.0,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.padding,
    this.margin,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: _onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: NeumorphicContainer(
          depth: widget.depth,
          borderRadius: widget.borderRadius,
          backgroundColor: widget.backgroundColor,
          padding: widget.padding,
          margin: widget.margin,
          isPressed: _isPressed,
          child: widget.child,
        ),
      ),
    );
  }
}

class NeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;

  const NeumorphicTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Stack(
        children: [
          // Outer shadow (atas-kiri)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withAlpha((255 * 0.8).round()),
                    offset: const Offset(-4, -4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          // Outer shadow (bawah-kanan)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((255 * 0.18).round()),
                    offset: const Offset(6, 6),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          // Field utama dengan inner shadow
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              onChanged: onChanged,
              maxLines: maxLines,
              enabled: enabled,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText ?? labelText,
                hintStyle: TextStyle(
                  color: Colors.grey[350],
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
                prefixIcon: prefixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: Colors.grey[350],
                          size: 22,
                        ),
                        child: prefixIcon!,
                      )
                    : null,
                suffixIcon: suffixIcon,
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NeumorphicToggle extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onChanged;
  final List<String> options;
  final double height;
  final double borderRadius;

  const NeumorphicToggle({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.options,
    this.height = 50.0,
    this.borderRadius = 12.0,
  });

  @override
  State<NeumorphicToggle> createState() => _NeumorphicToggleState();
}

class _NeumorphicToggleState extends State<NeumorphicToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _updateAnimation();
  }

  @override
  void didUpdateWidget(NeumorphicToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    final targetValue = widget.selectedIndex / (widget.options.length - 1);
    _animationController.animateTo(targetValue);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: widget.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final bool isActive = index == widget.selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => widget.onChanged(index),
            child: NeumorphicContainer(
              isPressed: isActive,
              depth: 8.0,
              borderRadius: widget.borderRadius,
              backgroundColor: isActive ? Colors.white : const Color(0xFFE0E5EC),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: Container(
                height: widget.height,
                alignment: Alignment.center,
                child: Text(
                  option,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isActive ? theme.primaryColor : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final double depth;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.depth = 6.0,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      depth: depth,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: child,
    );
  }
} 