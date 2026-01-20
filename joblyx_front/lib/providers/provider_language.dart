import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languageKey = 'language';

final languageProvider =
    NotifierProvider<LanguageNotifier, Locale?>(LanguageNotifier.new);

class LanguageNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    _loadLanguage();
    return null; 
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languageKey);
    state = _localeFromString(code);
  }

  Future<void> setLanguage(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();
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
