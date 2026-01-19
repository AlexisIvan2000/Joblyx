import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/widgets/settings/app_color_mode.dart';
import 'package:joblyx_front/widgets/settings/app_language.dart';

class AppPreferences extends StatelessWidget   {
  const AppPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // final cs = Theme.of(context).colorScheme;
    
    return Card(
      color: Colors.grey[300],
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          ListTile(
            title: Text(
              t.t('settings.color_mode'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showColorModeSheet(context),
          ),
          Divider(height: 1.h, color:  Colors.grey[400]),
          ListTile(
            title: Text(
              t.t('settings.change_language'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLanguageSheet(context),
          ),
        ],
      ),
    );
  }

}