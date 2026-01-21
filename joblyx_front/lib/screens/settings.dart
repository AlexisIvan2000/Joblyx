import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/widgets/settings/app_preferences.dart';
import 'package:joblyx_front/widgets/settings/documents.dart';
import 'package:joblyx_front/widgets/settings/log_out.dart';
import 'package:joblyx_front/widgets/settings/support.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text(
          t.t('settings.title'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.t('settings.app_preferences'),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            const AppPreferences(),
            const SizedBox(height: 2),
            Text(
              t.t('settings.documentation'),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            const Documents(),
            const SizedBox(height: 2),
            Text(
              t.t('settings.support'),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            const Support(),
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
                  SizedBox(height: 2.h),
                  Text(
                    t.t('settings.version'),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
      ),
    );
  }
}
