import './database.dart' as database;
import './theme.dart';

const SETTINGS_KEY = 'settings';
const FONT_SIZE_KEY = 'font_size';
const THEME_KEY = 'theme';

abstract class ThemeChangeListener {
  void onThemeChange();
}

class _Settings {
  Map<String, dynamic> _settingForKey;
  ThemeChangeListener themeChangeListener;

  Future init() async {
    await database.init();
    _settingForKey = database.getValueForKey(SETTINGS_KEY) ?? Map<String, dynamic>();
  }

  int get fontSize {
    return _settingForKey[FONT_SIZE_KEY] ?? 2;
  }

  set fontSize(int fontSize) {
    _settingForKey[FONT_SIZE_KEY] = fontSize;
    database.setValueForKey(SETTINGS_KEY, _settingForKey);
  }

  AppTheme get theme {
    return _settingForKey[THEME_KEY] == null ? AppTheme.Dark : AppTheme.values[_settingForKey[THEME_KEY]];
  }

  set theme(AppTheme theme) {
    _settingForKey[THEME_KEY] = theme.index;
    database.setValueForKey(SETTINGS_KEY, _settingForKey);

    if (themeChangeListener != null) {
      themeChangeListener.onThemeChange();
    }
  }
}

final instance = _Settings();
