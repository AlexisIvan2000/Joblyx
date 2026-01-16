import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const ScreenIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin:  EdgeInsets.symmetric(horizontal: 4.w),
          width: currentPage == index ? 20.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: currentPage == index
                ? cs.primary
                : cs.outlineVariant,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
