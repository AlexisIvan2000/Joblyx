import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';

void showLogOutDialog(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context);
  final cs = Theme.of(context).colorScheme;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          t.t('settings.logout_confirmation_message'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: cs.onSurface),
        ),
        contentPadding: EdgeInsets.all(16.w),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Text(
                  t.t('settings.cancel'),
                  style: TextStyle(fontSize: 16, color: cs.onSurface),
                ),
              ),
              SizedBox(width: 12.w),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await ref.read(authServiceProvider).logoutUser();
                  if (context.mounted){
                    context.go('/login');
                  }
                },
                child: Text(
                  t.t('settings.confirm'),
                  style: TextStyle(fontSize: 16, color: cs.error),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
