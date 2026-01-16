import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSnackBar {
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final cs = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        margin:  EdgeInsets.all(16.w),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: cs.errorContainer,
        content: Row(
          children: [
            Icon(Icons.error_outline, color: cs.onErrorContainer),
             SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: cs.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final cs = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin:  EdgeInsets.all(16.w),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: cs.primaryContainer,
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: cs.onPrimaryContainer),
             SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: cs.onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}