import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StadiumButton extends StatelessWidget {
  const StadiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppColors.surfaceMuted,
    this.foregroundColor = AppColors.textPrimary,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 220,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Text(label),
      ),
    );
  }
}
