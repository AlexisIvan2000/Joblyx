import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:joblyx_front/services/app_localizations.dart';

void showAboutSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => const AboutWidget(),
  );
}

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final t = AppLocalizations.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        left: 16.w,
        right: 16.w,
        top: 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 45.r,
                backgroundColor: cs.surface,
                backgroundImage: const AssetImage('assets/images/logo_j.png'),
              ),
              SizedBox(width: 12.w),
              Text(
                'Joblyx',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: cs.primary, fontSize: 20.sp
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Center(
            child: Text('Version 1.0.0', style: theme.textTheme.bodyMedium),
          ),
          SizedBox(height: 20.h),

        ],
      ),
    );
  }
}
