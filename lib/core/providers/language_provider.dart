import 'package:flutter/material.dart';

enum AppLanguage { en, si, ta }

class LanguageProvider extends ChangeNotifier {
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

  void setLanguage(AppLanguage lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  // Multi-Language Translation Dictionary
  static final Map<String, Map<AppLanguage, String>> _localizedStrings = {
    'welcome_title': {
      AppLanguage.en: 'Your Fitness Journey Starts Here',
      AppLanguage.si: 'ඔබේ ශාරීරික සුවතා ගමන මෙතැනින් ඇරඹේ',
      AppLanguage.ta: 'ඔබේ உடற்பயிற்சி பயணம் இங்கே தொடங்குகிறது',
    },
    'dashboard': {
      AppLanguage.en: 'Dashboard',
      AppLanguage.si: 'ප්‍රධාන පුවරුව (Dashboard)',
      AppLanguage.ta: 'முகப்புப்பலகை',
    },
    'todays_workout': {
      AppLanguage.en: 'TODAY\'S WORKOUT',
      AppLanguage.si: 'අද දින ව්‍යායාමය',
      AppLanguage.ta: 'இன்றைய உடற்பயிற்சி',
    },
    'start_workout': {
      AppLanguage.en: 'Start Workout',
      AppLanguage.si: 'ව්‍යායාමය ආරම්භ කරන්න',
      AppLanguage.ta: 'உடற்பயிற்சியை தொடங்கு',
    },
    'progress': {
      AppLanguage.en: 'Your Progress',
      AppLanguage.si: 'ඔබේ ප්‍රගතිය',
      AppLanguage.ta: 'உங்கள் முன்னேற்றம்',
    },
    'history': {
      AppLanguage.en: 'View History',
      AppLanguage.si: 'ඉතිහාසය බලන්න',
      AppLanguage.ta: 'வரலாற்றைப் பார்க்கவும்',
    },
    'notifications': {
      AppLanguage.en: 'Notifications',
      AppLanguage.si: 'දැනුම්දීම් (Notifications)',
      AppLanguage.ta: 'அறிவிப்புகள்',
    },
    'settings': {
      AppLanguage.en: 'Settings',
      AppLanguage.si: 'සැකසුම් (Settings)',
      AppLanguage.ta: 'அமைப்புகள்',
    },
    'create_workout': {
      AppLanguage.en: 'Create Workout',
      AppLanguage.si: 'නව ව්‍යායාමයක් සාදන්න',
      AppLanguage.ta: 'உடற்பயிற்சியை உருவாக்கு',
    },
    'safety_content': {
      AppLanguage.en: 'Safety Content',
      AppLanguage.si: 'ආරක්ෂිත උපදෙස්',
      AppLanguage.ta: 'பாதுகாப்பு வழிகாட்டுதல்',
    },
    'logout': {
      AppLanguage.en: 'Log Out',
      AppLanguage.si: 'පිටවෙන්න (Log Out)',
      AppLanguage.ta: 'வெளியேறு',
    },
  };

  String translate(String key) {
    if (_localizedStrings.containsKey(key)) {
      return _localizedStrings[key]![_currentLanguage] ?? key;
    }
    return key;
  }
}
