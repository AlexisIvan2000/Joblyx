import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';

void showColorModeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => const AppColorMode(),
  );
}

class AppColorMode extends StatefulWidget {
  const AppColorMode({super.key});

  @override
  State<AppColorMode> createState() => _AppColorModeState();
}

class _AppColorModeState extends State<AppColorMode> {
  String _selectedMode = 'system';

  void _onModeChanged(String value) {
    setState(() => _selectedMode = value);
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
            t.t('settings.color_mode'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          RadioGroup<String>(
            groupValue: _selectedMode,
            onChanged: (value) => _onModeChanged(value!),
            child: Column(
              children: [
                _ColorModeOption(
                  title: t.t('settings.system'),
                  value: 'system',
                  onTap: _onModeChanged,
                ),
                _ColorModeOption(
                  title: t.t('settings.light'),
                  value: 'light',
                  onTap: _onModeChanged,
                ),
                _ColorModeOption(
                  title: t.t('settings.dark'),
                  value: 'dark',
                  onTap: _onModeChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorModeOption extends StatelessWidget {
  final String title;
  final String value;
  final ValueChanged<String> onTap;

  const _ColorModeOption({
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
