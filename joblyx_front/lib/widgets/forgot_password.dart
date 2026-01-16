import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';

void showForgotPasswordDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  final cs = Theme.of(context).colorScheme;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: cs.surface,
        contentPadding: EdgeInsets.all(16.w),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Column(
            children: [
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.t('login.forgot_password_title'),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: cs.onSurface),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: Icon(
                      Icons.close,
                      color: cs.onSurface,
                    ),
                  ),

                ],
              ),
              SizedBox(height: 15.h),
              Text(
                t.t('login.forgot_password_message'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              TextField(
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(t.t('login.send')),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
