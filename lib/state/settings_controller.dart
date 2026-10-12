import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/music_folder.dart';
import '../theme/app_theme.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs);

  final SharedPreferences _prefs;

  static Future<SettingsController> load() async {
    return SettingsController(await SharedPreferences.getInstance());
  }

  static const _kTheme = 'theme';
  static const _kSort = 'sort';
  static const _kReduceMotion = 'reduce_motion';

  AppThemeName get theme =>
      AppThemeName.values.firstWhere((v) => v.name == _prefs.getString(_kTheme),
          orElse: () => AppThemeName.persona3);

  SongSortOption get sortOption => SongSortOption.byId(_prefs.getString(_kSort));

  bool get reduceMotion => _prefs.getBool(_kReduceMotion) ?? false;

  Future<void> setTheme(AppThemeName value) async {
    await _prefs.setString(_kTheme, value.name);
    notifyListeners();
  }

  Future<void> setSortOption(SongSortOption value) async {
    await _prefs.setString(_kSort, value.id);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    await _prefs.setBool(_kReduceMotion, value);
    notifyListeners();
  }
}
