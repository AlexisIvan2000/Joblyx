import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/widgets/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

void showContactUsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => const ContactUsWidget(),
  );
}

class ContactUsWidget extends StatelessWidget {
  const ContactUsWidget({super.key});

  Future<void> _sendEmail(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@joblyx.com',
      queryParameters: {'subject': 'Support/Suggestions'},
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          AppSnackBar.showError(context, t.t('settings.email_error'));
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, t.t('settings.email_error'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final cs = theme.colorScheme;

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
            t.t('settings.contact_us'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            t.t('settings.contact_message'),
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 12.h),
          Center(
            child: Column(
              children: [
                InkWell(
                  onTap: () => _sendEmail(context),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    child: Text(
                      t.t('settings.contact_email'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  t.t('settings.contact_response_time'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
