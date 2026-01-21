import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/providers/shared_preferences_provider.dart';

const _languageKey = 'language';

final languageProvider =
    NotifierProvider<LanguageNotifier, Locale?>(LanguageNotifier.new);

class LanguageNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_languageKey);
    return _localeFromString(code);
  }

  Future<void> setLanguage(String? languageCode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (languageCode == null || languageCode == 'sys') {
      state = null;
      await prefs.remove(_languageKey);
    } else {
      state = Locale(languageCode);
      await prefs.setString(_languageKey, languageCode);
    }
  }

  Locale? _localeFromString(String? code) {
    if (code == null || code == 'sys') return null;
    return Locale(code);
  }
}
