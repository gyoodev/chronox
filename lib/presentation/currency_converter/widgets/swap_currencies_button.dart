import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SwapCurrenciesButton extends StatefulWidget {
  final VoidCallback onSwap;

  const SwapCurrenciesButton({Key? key, required this.onSwap})
    : super(key: key);

  @override
  State<SwapCurrenciesButton> createState() => _SwapCurrenciesButtonState();
}

class _SwapCurrenciesButtonState extends State<SwapCurrenciesButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSwap() {
    _animationController.forward().then((_) {
      _animationController.reset();
    });
    widget.onSwap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleSwap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.3,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 3.14159,
              child: CustomIconWidget(
                iconName: 'swap_vert',
                color: Colors.white,
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }
}
