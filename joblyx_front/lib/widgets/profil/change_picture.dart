import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/providers/storage_service_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/services/storage_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showChangePictureDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (_) => _ChangePictureDialog(ref: ref),
  );
}

/// Dialog extrait en widget séparé pour éviter les recreations inutiles
class _ChangePictureDialog extends StatelessWidget {
  final WidgetRef ref;

  // ImagePicker en static pour éviter les réinstanciations
  static final _picker = ImagePicker();

  const _ChangePictureDialog({required this.ref});

  Future<void> _pickAndUpload(
    BuildContext context,
    ImageSource source,
    AppLocalizations t,
  ) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile == null) return;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final String newUrl = await ref
          .read(storageServiceProvider)
          .uploadProfilePicture(userId, File(pickedFile.path));
      await ref.read(authServiceProvider).updateUserProfile('profile_picture', newUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.t('profil.picture_updated'))),
        );
      }
    } on StorageFailure catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.t('err.${e.code}'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.t('err.unknown_error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      backgroundColor: cs.surface,
      title: Text(
        t.t('profil.change_picture'),
        style: textTheme.titleMedium?.copyWith(color: cs.onSurface),
      ),
      contentPadding: EdgeInsets.all(16.w),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      actions: [
        Column(
          children: [
            _ActionButton(
              label: t.t('profil.take_photo'),
              filled: true,
              onPressed: () async {
                Navigator.of(context).pop();
                await _pickAndUpload(context, ImageSource.camera, t);
              },
            ),
            SizedBox(height: 12.h),
            _ActionButton(
              label: t.t('profil.choose_from_gallery'),
              filled: false,
              onPressed: () async {
                Navigator.of(context).pop();
                await _pickAndUpload(context, ImageSource.gallery, t);
              },
            ),
            SizedBox(height: 12.h),
            _InfoTexts(
              maxFileSizeText: t.t('profil.max_file_size'),
              fileTypeText: t.t('profil.file_type'),
              style: textTheme.bodySmall?.copyWith(
                color: cs.onSurface,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Bouton d'action extrait pour réutilisabilité
class _ActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  static const _textStyle = TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: filled
          ? FilledButton(
              onPressed: onPressed,
              child: Text(label, style: _textStyle),
            )
          : OutlinedButton(
              onPressed: onPressed,
              child: Text(label, style: _textStyle),
            ),
    );
  }
}

/// Textes d'information extraits
class _InfoTexts extends StatelessWidget {
  final String maxFileSizeText;
  final String fileTypeText;
  final TextStyle? style;

  const _InfoTexts({
    required this.maxFileSizeText,
    required this.fileTypeText,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(maxFileSizeText, style: style),
        SizedBox(height: 4.h),
        Text(fileTypeText, style: style),
      ],
    );
  }
}
