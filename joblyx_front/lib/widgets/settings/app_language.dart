import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';

void showLanguageSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => const AppLanguage(),
  );
}

class AppLanguage extends StatefulWidget {
  const AppLanguage({super.key});

  @override
  State<AppLanguage> createState() => _AppLanguageState();
}

class _AppLanguageState extends State<AppLanguage> {
  String _selectedLanguage = 'sys';

  void _onLanguageChanged(String value) {
    setState(() => _selectedLanguage = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

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
            groupValue: _selectedLanguage,
            onChanged: (value) => _onLanguageChanged(value!),
            child: Column(
              children: [
                _LanguageOption(
                  title: t.t('settings.system'), 
                  value: 'sys', 
                  onTap: _onLanguageChanged,
                ),
                _LanguageOption(
                  title: t.t('settings.french'),
                  value: 'fr',
                  onTap: _onLanguageChanged,
                ),
                _LanguageOption(
                  title: t.t('settings.english'),
                  value: 'en',
                  onTap: _onLanguageChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String value;
  final ValueChanged<String> onTap;

  const _LanguageOption({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Radio<String>(value: value),
      onTap: () => onTap(value),
    );
  }
}
