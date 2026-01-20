import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/provider_language.dart';
import 'package:joblyx_front/services/app_localizations.dart';

void showLanguageSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => const AppLanguage(),
  );
}

class AppLanguage extends ConsumerWidget {
  const AppLanguage({super.key});

  String _localeToCode(Locale? locale) {
    if (locale == null) return 'sys';
    return locale.languageCode;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final currentLocale = ref.watch(languageProvider);
    final currentCode = _localeToCode(currentLocale);

    void onLanguageChanged(String? code) {
      if (code != null) {
        ref.read(languageProvider.notifier).setLanguage(code);
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
            t.t('settings.change_language'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          RadioGroup<String>(
            groupValue: currentCode,
            onChanged: onLanguageChanged,
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(t.t('settings.system')),
                  value: 'sys',
                ),
                RadioListTile<String>(
                  title: Text(t.t('settings.french')),
                  value: 'fr',
                ),
                RadioListTile<String>(
                  title: Text(t.t('settings.english')),
                  value: 'en',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
