import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/providers/storage_service_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showChangePictureDialog(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context);
  final cs = Theme.of(context).colorScheme;
  final picker = ImagePicker();

  Future<void> pickAndUpload(ImageSource source) async{
    try{
     final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile == null) return;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final String newUrl = await ref.read(storageServiceProvider).uploadProfilePicture(userId, File(pickedFile.path));
      await ref.read(authServiceProvider).updateUserProfile('profile_picture', newUrl);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.t('profil.picture_updated'))),
        );
      }
    } catch (e){
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.t('profil.picture_update_failed'))),
        );
      }
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          t.t('profil.change_picture'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: cs.onSurface),
        ),
        contentPadding: EdgeInsets.all(16.w),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: FilledButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await pickAndUpload(ImageSource.camera);
                  },
                  child: Text(
                    t.t('profil.take_photo'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: OutlinedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await pickAndUpload(ImageSource.gallery);
                  },
                  child: Text(
                    t.t('profil.choose_from_gallery'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      t.t('profil.max_file_size'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurface,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      t.t('profil.file_type'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurface,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    },
  );
}
