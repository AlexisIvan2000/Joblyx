import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/widgets/settings/account_settings.dart';
import 'package:joblyx_front/widgets/settings/documents.dart';
import 'package:joblyx_front/widgets/settings/log_out.dart';
import 'package:joblyx_front/widgets/settings/support.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text(
          t.t('settings.title'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.t('settings.account_settings'),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 2.h),
            const AccountSettings(),
            SizedBox(height: 2.h),
            Text(
              t.t('settings.documentation'),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 2.h),
            const Documents(),
            SizedBox(height: 2.h),
            Text(
              t.t('settings.support'),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 2.h),
            const Support(),
            SizedBox(height: 24.h),
             SizedBox(
              width: double.infinity,
              height: 52.h,
              child: FilledButton.icon(
                icon: Icon(Icons.logout, color: Colors.white, size: 20.r),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(cs.error),
                ),
                onPressed: () {
                  showLogOutDialog(context, ref);
                },
                label: Text(
                  t.t('settings.logout'),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
      
          ],
        ),
      )
    );
  }
}