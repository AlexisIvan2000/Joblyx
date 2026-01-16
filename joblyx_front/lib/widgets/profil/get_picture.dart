import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:joblyx_front/providers/user_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/widgets/profil/change_picture.dart';
import 'package:joblyx_front/widgets/profile_avatar.dart';

class GetPicture extends ConsumerWidget {
  const GetPicture({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = AppLocalizations.of(context);
    final pictureDataAsync = ref.watch(userPictureCardProvider);

    return pictureDataAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.all(16.h),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => Text(
        t.t('err.error'),
        style: textTheme.bodyMedium?.copyWith(color: cs.error),
      ),
      data: (pictureData) {
        if (pictureData.createdAt == null) {
          return const SizedBox.shrink();
        }

        final formattedDate = DateFormat.yMMMMd(
          Localizations.localeOf(context).languageCode,
        ).format(pictureData.createdAt!);

        return Card(
          color: Colors.grey[300],
          margin: EdgeInsets.symmetric(vertical: 16.h),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AvatarWithCamera(
                  imageUrl: pictureData.profilePicture,
                  primaryColor: cs.primary,
                  onPrimaryColor: cs.onPrimary,
                  onCameraTap: () => showChangePictureDialog(context, ref),
                ),
                SizedBox(width: 12.w),
                _UserInfo(
                  meText: t.t('profil.me'),
                  memberSinceText: t.t('profil.member_since'),
                  formattedDate: formattedDate,
                  textTheme: textTheme,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AvatarWithCamera extends StatelessWidget {
  final String? imageUrl;
  final Color primaryColor;
  final Color onPrimaryColor;
  final VoidCallback onCameraTap;

  const _AvatarWithCamera({
    required this.imageUrl,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ProfileAvatar(
          imageUrl: imageUrl,
          radius: 45.r,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 14.r,
            backgroundColor: primaryColor,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.camera_alt,
                size: 14.r,
                color: onPrimaryColor,
              ),
              onPressed: onCameraTap,
            ),
          ),
        ),
      ],
    );
  }
}

/// Informations utilisateur extraites
class _UserInfo extends StatelessWidget {
  final String meText;
  final String memberSinceText;
  final String formattedDate;
  final TextTheme textTheme;

  const _UserInfo({
    required this.meText,
    required this.memberSinceText,
    required this.formattedDate,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meText,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          memberSinceText,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          formattedDate,
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}
