import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:joblyx_front/providers/user_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/widgets/profil/change_picture.dart';


class GetPicture extends ConsumerWidget {
  const GetPicture({super.key});

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
      error: (_, __) => Text(t.t('err.error'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.error),),
      data: (user) {
        if (user == null){
          return const SizedBox.shrink();
        }
        final formattedDate = DateFormat.yMMMMd(Localizations.localeOf(context).languageCode).format(user.createdAt);
        return  Card(
      color: Colors.grey[300],
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 45.r,
                    backgroundImage: user.profilePicture.isNotEmpty
                        ? NetworkImage(user.profilePicture)
                        : const AssetImage('assets/images/profile.png')
                              as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 14.r,
                      backgroundColor: cs.primary,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.camera_alt,
                          size: 14.r,
                          color: cs.onPrimary,
                        ),
                        onPressed: () {
                          showChangePictureDialog(context, ref);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.t('profil.me'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    t.t('profil.member_since'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15.h),
          
        ],
      ),
    );
      }
    );
  }
}
