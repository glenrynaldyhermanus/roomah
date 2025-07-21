import 'package:flutter/material.dart';

class CustomNeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double depth;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isPressed;

  const CustomNeumorphicContainer({
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
                  color: darkColor.withOpacity(0.5),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: lightColor.withOpacity(0.5),
                  offset: const Offset(-3, -3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ]
            : [
                BoxShadow(
                  color: darkColor.withOpacity(0.6),
                  offset: Offset(depth, depth),
                  blurRadius: depth * 1.5,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: lightColor.withOpacity(0.6),
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

class CustomNeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double depth;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CustomNeumorphicButton({
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
  State<CustomNeumorphicButton> createState() => _CustomNeumorphicButtonState();
}

class _CustomNeumorphicButtonState extends State<CustomNeumorphicButton>
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
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: CustomNeumorphicContainer(
              depth: widget.depth,
              borderRadius: widget.borderRadius,
              backgroundColor: widget.backgroundColor,
              padding: widget.padding,
              margin: widget.margin,
              isPressed: _isPressed,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class CustomNeumorphicTextField extends StatelessWidget {
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

  const CustomNeumorphicTextField({
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
    return CustomNeumorphicContainer(
      depth: 6.0,
      borderRadius: 16.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      isPressed: true, // Debossed effect
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelStyle: TextStyle(
            color: enabled ? Colors.grey[700] : Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[500],
          ),
        ),
        style: TextStyle(
          color: enabled ? Colors.black87 : Colors.grey[600],
          fontSize: 16,
        ),
      ),
    );
  }
}

class CustomNeumorphicToggle extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onChanged;
  final List<String> options;
  final double height;
  final double borderRadius;

  const CustomNeumorphicToggle({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.options,
    this.height = 50.0,
    this.borderRadius = 12.0,
  });

  @override
  State<CustomNeumorphicToggle> createState() => _CustomNeumorphicToggleState();
}

class _CustomNeumorphicToggleState extends State<CustomNeumorphicToggle>
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
  void didUpdateWidget(CustomNeumorphicToggle oldWidget) {
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
            child: CustomNeumorphicContainer(
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

class CustomNeumorphicCard extends StatelessWidget {
  final Widget child;
  final double depth;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  const CustomNeumorphicCard({
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
    return CustomNeumorphicContainer(
      depth: depth,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: child,
    );
  }
} 