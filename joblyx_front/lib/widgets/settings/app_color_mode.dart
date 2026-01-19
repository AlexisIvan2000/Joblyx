import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/provider_theme_color.dart';
import 'package:joblyx_front/services/app_localizations.dart';

void showColorModeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => const AppColorMode(),
  );
}

class AppColorMode extends ConsumerWidget {
  const AppColorMode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final currentMode = ref.watch(themeModeProvider);

    void onModeChanged(ThemeMode? mode) {
      if (mode != null) {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      }
    }

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
          Text(
            t.t('settings.color_mode'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          RadioGroup<ThemeMode>(
            groupValue: currentMode,
            onChanged: onModeChanged,
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(t.t('settings.system')),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(t.t('settings.light')),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(t.t('settings.dark')),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
