import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/user_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/widgets/profil/edit_field_sheet.dart';
import 'package:joblyx_front/widgets/profil/change_email.dart';
import 'package:joblyx_front/widgets/profil/change_password.dart';

class PersonalDetails extends ConsumerWidget {
  const PersonalDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = AppLocalizations.of(context);
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.all(16.h),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => Text(
        t.t('err.error'),
        style: textTheme.bodyMedium?.copyWith(color: cs.error),
      ),
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        
        final labelStyle = textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
        final valueStyle = textTheme.bodyMedium;

        return Card(
          color: Colors.grey[300],
          margin: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            children: [
              _DetailTile(
                label: t.t('register.first_name'),
                value: user.firstName.isNotEmpty ? user.firstName : '-----',
                labelStyle: labelStyle,
                valueStyle: valueStyle,
                onTap: () => _showEditSheet(
                  context,
                  cs.surface,
                  t.t('register.first_name'),
                  'first_name',
                  user.firstName,
                ),
              ),
              _buildDivider(),
              _DetailTile(
                label: t.t('register.last_name'),
                value: user.lastName.isNotEmpty ? user.lastName : '-----',
                labelStyle: labelStyle,
                valueStyle: valueStyle,
                onTap: () => _showEditSheet(
                  context,
                  cs.surface,
                  t.t('register.last_name'),
                  'last_name',
                  user.lastName,
                ),
              ),
              _buildDivider(),
              _EmailTile(
                label: t.t('register.email'),
                value: user.email.isNotEmpty ? user.email : 'user@gmail.com',
                labelStyle: labelStyle,
                valueStyle: valueStyle,
                onTap: () => showChangeEmailSheet(context),
              ),
              _buildDivider(),
              _DetailTile(
                label: t.t('register.password'),
                value: '***********',
                labelStyle: labelStyle,
                valueStyle: valueStyle,
                onTap: () => showChangePasswordSheet(context),
              ),
              _buildDivider(),
              ListTile(
                title: Text(
                  t.t('profil.delete_account'),
                  style: labelStyle,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1.h, color: Colors.grey[400]);
  }

  void _showEditSheet(
    BuildContext context,
    Color backgroundColor,
    String title,
    String field,
    String initialValue,
  ) {
    showModalBottomSheet(
      backgroundColor: backgroundColor,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (context) => EditFieldSheet(
        title: title,
        field: field,
        initialValue: initialValue,
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final VoidCallback onTap;

  const _DetailTile({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}


class _EmailTile extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final VoidCallback onTap;

  const _EmailTile({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
