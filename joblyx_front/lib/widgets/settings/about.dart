import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';

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
    final t = AppLocalizations.of(context);
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
          Center(
            child: Column(
              children: [
                Text(
                  'Joblyx',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.secondary,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  t.t('settings.version'),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              t.t('settings.copyright'),
              style: theme.textTheme.titleSmall,
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
