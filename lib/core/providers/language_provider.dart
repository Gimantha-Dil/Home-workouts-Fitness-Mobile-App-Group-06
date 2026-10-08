import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { en, si, ta }

extension TranslationExtension on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    return watch<LanguageProvider>().translate(key, params: params);
  }
}

class LanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_language';
  AppLanguage _currentLanguage = AppLanguage.en;

  AppLanguage get currentLanguage => _currentLanguage;

  String get languageName {
    switch (_currentLanguage) {
      case AppLanguage.en:
        return 'English (US)';
      case AppLanguage.si:
        return 'Sinhala (සිංහල)';
      case AppLanguage.ta:
        return 'Tamil (தமிழ்)';
    }
  }

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null) {
        final lang = AppLanguage.values.firstWhere(
              (l) => l.name == code,
          orElse: () => AppLanguage.en,
        );
        _currentLanguage = lang;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved language preference: $e');
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _currentLanguage = lang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, lang.name);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  // Multi-Language Translation Dictionary
  static final Map<String, Map<AppLanguage, String>> _localizedStrings = {
    // Common & Navigation
    'app_name': {
      AppLanguage.en: 'FitPulse',
      AppLanguage.si: 'FitPulse',
      AppLanguage.ta: 'FitPulse',
    },
    'welcome_title': {
      AppLanguage.en: 'Your Fitness Journey Starts Here',
      AppLanguage.si: 'ඔබේ ශාරීරික සුවතා ගමන මෙතැනින් ඇරඹේ',
      AppLanguage.ta: '\u0b8d\u0ba4\u0bc1\u0baa\u0baf\u0bbf\u0bb1\u0bcd\u0b9a\u0bbf \u0baa\u0baf\u0ba3\u0bae\u0bcd \u0b8d\u0b92\u0b99\u0bcd\u0b95\u0bc7 \u0ba4\u0bca\u0b9f\u0b99\u0bcd\u0b95\u0bc1\u0b95\u0bbf\u0bb1\u0ba4\u0bc1',
    },
    'dashboard': {
      AppLanguage.en: 'Dashboard',
      AppLanguage.si: 'ප්‍රධාන පුවරුව',
      AppLanguage.ta: '\u0bae\u0bc1\u0b95\u0baa\u0bcd\u0baa\u0bc1\u0baa\u0bcd\u0baa\u0bb2\u0b95\u0bc8',
    },
    'todays_workout': {
      AppLanguage.en: 'TODAY\'S WORKOUT',
      AppLanguage.si: 'අද දින ව්‍යායාමය',
      AppLanguage.ta: '\u0b87\u0ba9\u0bcd\u0bb1\u0bc8\u0baf \u0b8d\u0ba4\u0bc1\u0baa\u0baf\u0bbf\u0bb1\u0bcd\u0b9a\u0bbf',
    },
    'start_workout': {
      AppLanguage.en: 'Start Workout',
      AppLanguage.si: 'ව්‍යායාමය ආරම්භ කරන්න',
      AppLanguage.ta: '\u0b8d\u0ba4\u0bc1\u0baa\u0baf\u0bbf\u0bb1\u0bcd\u0b9a\u0bbf\u0baf\u0bc8 \u0ba4\u0bca\u0b9f\u0b99\u0bcd\u0b95\u0bc1',
    },
    'progress': {
      AppLanguage.en: 'Your Progress',
      AppLanguage.si: 'ඔබේ ප්‍රගතිය',
      AppLanguage.ta: '\u0b8d\u0b99\u0bcd\u0b95\u0bb3\u0bcd \u0bae\u0bc1\u0ba9\u0bcd\u0ba9\u0bc7\u0bb1\u0bcd\u0bb1\u0bae\u0bcd',
    },
    'history': {
      AppLanguage.en: 'View History',
      AppLanguage.si: 'ඉතිහාසය බලන්න',
      AppLanguage.ta: '\u0bb5\u0bb0\u0bb2\u0baf\u0bbf\u0bb1\u0bcd\u0bb1\u0bc8\u0baa\u0bcd \u0baa\u0baf\u0bbf\u0bb0\u0bcd\u0b95\u0bcd\u0b95\u0bb5\u0bc1\u0bae\u0bcd',
    },
    'notifications': {
      AppLanguage.en: 'Notifications',
      AppLanguage.si: 'දැනුම්දීම්',
      AppLanguage.ta: '\u0b85\u0bb1\u0bbf\u0bb5\u0bbf\u0baa\u0bcd\u0baa\u0bc1\u0b95\u0bb3\u0bcd',
    },
    'settings': {
      AppLanguage.en: 'Settings',
      AppLanguage.si: 'සැකසුම්',
      AppLanguage.ta: '\u0b85\u0bae\u0bc8\u0baa\u0bcd\u0baa\u0bc1\u0b95\u0bb3\u0bcd',
    },
    'profile': {
      AppLanguage.en: 'Profile',
      AppLanguage.si: 'පැතිකඩ',
      AppLanguage.ta: '\u0b9a\u0bc1\u0baf\u0bb5\u0bbf\u0bb5\u0bb0\u0bae\u0bcd',
    },
    'create_workout': {
      AppLanguage.en: 'Create Workout',
      AppLanguage.si: 'නව ව්‍යායාමයක් සාදන්න',
      AppLanguage.ta: '\u0b8d\u0ba4\u0bc1\u0baa\u0baf\u0bbf\u0bb1\u0bcd\u0b9a\u0bbf\u0baf\u0bc8 \u0b8d\u0bb0\u0bc1\u0bb5\u0bbe\u0b95\u0bcd\u0b95\u0bc1',
    },
    'safety_content': {
      AppLanguage.en: 'Safety Content',
      AppLanguage.si: 'ආරක්ෂිත උපදෙස්',
      AppLanguage.ta: '\u0baa\u0bbe\u0ba4\u0bc1\u0b95\u0bbe\u0baa\u0bcd\u0baa\u0bc1 \u0bb5\u0bb4\u0bbf\u0b95\u0bbe\u0b9f\u0bcd\u0b9f\u0bc1\u0ba4\u0bb2\u0bcd',
    },
    'logout': {
      AppLanguage.en: 'Log Out',
      AppLanguage.si: 'පිටවෙන්න',
      AppLanguage.ta: '\u0bb5\u0bc6\u0bb3\u0bbf\u0baf\u0bc7\u0bb1\u0bc1',
    },
    'login': {
      AppLanguage.en: 'Log In',
      AppLanguage.si: 'ඇතුළු වන්න',
      AppLanguage.ta: '\u0b8d\u0bb3\u0bcd\u0ba9\u0bc1\u0bb4\u0bc8\u0b95',
    },
    'signup': {
      AppLanguage.en: 'Sign Up',
      AppLanguage.si: 'ලියාපදිංචි වන්න',
      AppLanguage.ta: '\u0baa\u0ba4\u0bbf\u0bb5\u0bc1 \u0b9a\u0bc6\u0baf\u0bcd\u0b95',
    },
    'email_address': {
      AppLanguage.en: 'Email Address',
      AppLanguage.si: 'විද්‍යුත් තැපැල් ලිපිනය',
      AppLanguage.ta: '\u0bae\u0bbf\u0ba9\u0bcd\u0ba9\u0b9e\u0bcd\u0b9a\u0bb2\u0bcd \u0bae\u0bc1\u0b95\u0bb5\u0bb0\u0bbf',
    },
    'password': {
      AppLanguage.en: 'Password',
      AppLanguage.si: 'මුරපදය',
      AppLanguage.ta: '\u0b95\u0b9f\u0bb5\u0bc1\u0b9a\u0bcd\u0b9a\u0bca\u0bb2\u0bcd',
    },
    'save_changes': {
      AppLanguage.en: 'Save Changes',
      AppLanguage.si: 'වෙනස්කම් සුරකින්න',
      AppLanguage.ta: '\u0bae\u0b9e\u0bcd\u0b9a\u0bb2\u0bcd\u0b9a\u0bc7\u0bae\u0bbf',
    },
    'cancel': {
      AppLanguage.en: 'Cancel',
      AppLanguage.si: 'අවලංගු කරන්න',
      AppLanguage.ta: '\u0bb0\u0ba4\u0bcd\u0ba4\u0bc1\u0b9a\u0bc6\u0baf\u0bcd',
    },
    'language': {
      AppLanguage.en: 'Language',
      AppLanguage.si: 'භාෂාව',
      AppLanguage.ta: '\u0bae\u0bca\u0bb4\u0bbf',
    },
    'greeting_user': {
      AppLanguage.en: 'Hello {name} 👋',
      AppLanguage.si: 'ආයුබෝවන් {name} 👋',
      AppLanguage.ta: '\u0bb5\u0ba3\u0b95\u0bcd\u0b95\u0bae\u0bcd {name} 👋',
    },
  };

  Map<String, Map<AppLanguage, String>> get localizedStrings => _localizedStrings;

  String translate(String key, {Map<String, String>? params}) {
    String text;
    if (_localizedStrings.containsKey(key)) {
      text = _localizedStrings[key]![_currentLanguage] ?? _localizedStrings[key]![AppLanguage.en] ?? key;
    } else {
      if (kDebugMode && _currentLanguage != AppLanguage.en) {
        debugPrint('⚠️ Missing translation key [$key] for ${_currentLanguage.name}');
      }
      text = key;
    }

    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, value) {
        text = text.replaceAll('{$paramKey}', value);
      });
    }

    return text;
  }
}
