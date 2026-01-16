import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';

class EditFieldSheet extends ConsumerStatefulWidget {
  final String title;
  final String field;
  final String initialValue;

  const EditFieldSheet({
    super.key,
    required this.title,
    required this.field,
    required this.initialValue,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditFieldSheetState();
}

class _EditFieldSheetState extends ConsumerState<EditFieldSheet> {
  late final TextEditingController _controller;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateUserProfile(widget.field, _controller.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('profil.profile_updated')),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('profil.update_failed')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

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
            widget.title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton(
              onPressed: _loading ? null : _save, 
              child: _loading
                ? CircularProgressIndicator(color: cs.onSurface, strokeWidth: 2,)
                : Text(t.t('profil.save'), style: TextStyle(fontSize: 16),),
            ),
          ),
        ],
      ),
    );
  }
}