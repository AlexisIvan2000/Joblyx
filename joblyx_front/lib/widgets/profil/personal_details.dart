import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/user_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/widgets/profil/edit_field_sheet.dart';

class PersonalDetails extends ConsumerWidget {
  const PersonalDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.all(16.h),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => Text(
        t.t('err.error'),
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: cs.error),
      ),
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }
        return Card(
          color: Colors.grey[300],
          margin: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.t('register.first_name'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user.firstName.isNotEmpty ? user.firstName : '-----',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: cs.surface,
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    builder: (context) => EditFieldSheet(
                      title: t.t('register.first_name'),
                      field: 'first_name',
                      initialValue: user.firstName,
                    ),
                  );
                },
              ),
              Divider(height: 1.h, color: Colors.grey[400]),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.t('register.last_name'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user.lastName.isNotEmpty ? user.lastName : '-----',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: cs.surface,
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    builder: (context) => EditFieldSheet(
                      title: t.t('register.last_name'),
                      field: 'last_name',
                      initialValue: user.lastName,
                    ),
                  );
                },
              ),
              Divider(height: 1.h, color: Colors.grey[400]),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.t('register.email'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        user.email.isNotEmpty ? user.email : 'user@gmail.com',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
              Divider(height: 1.h, color: Colors.grey[400]),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.t('register.password'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '***********',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
              Divider(height: 1.h, color: Colors.grey[400]),
              ListTile(
                title: Text(
                  t.t('profil.delete_account'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
