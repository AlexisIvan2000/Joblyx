import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';

class Documents extends StatelessWidget {
  const Documents({super.key});

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
              t.t('settings.about'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          Divider(height: 1.h, color:  Colors.grey[400]),
          ListTile(
            title: Text(
              t.t('settings.privacy_policy'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}