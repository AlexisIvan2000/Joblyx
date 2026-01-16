import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/user_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: userAsync.when(
          loading: () => SizedBox(
            height: 24.h,
            width: 24.w,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
          ),
          error: (_, __) => Text(t.t('err.error')),
          data: (user) {
            if (user == null) {
              return Text(t.t('home.welcome'));
            }
            return Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.surface,
                  radius: 24.r,
                  backgroundImage: user.profilePicture.isNotEmpty
                      ? NetworkImage(user.profilePicture)
                      : const AssetImage('assets/images/profile.png')
                            as ImageProvider,
                ),
                SizedBox(width: 12.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.t('home.welcome')} ${user.firstName}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Montreal, QC',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: Center(child: Text('Home Screen')),
    );
  }
}
