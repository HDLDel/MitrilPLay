import 'dart:collection';

import 'package:mitril_play/backend/sql.dart';
import 'package:mitril_play/models/settings.dart';
import 'package:mitril_play/models/view_type.dart';
import 'package:package_info_plus/package_info_plus.dart';

const defaultView = "defaultView";
const refreshOnStart = "refreshOnStart";
const showLivestreams = "showLivestreams";
const showMovies = "showMovies";
const showSeries = "showSeries";
const themeMode = "themeMode";
const lastSeenVersion = "lastSeenVersion";

class SettingsService {
  static Future<Settings> getSettings() async {
    var settingsMap = await Sql.getSettings();
    var settings = Settings();
    var view = settingsMap[defaultView];
    var refresh = settingsMap[refreshOnStart];
    var live = settingsMap[showLivestreams];
    var movies = settingsMap[showMovies];
    var series = settingsMap[showSeries];
    var theme = settingsMap[themeMode];
    if (view != null) {
      settings.defaultView = ViewType.values[int.parse(view)];
    }
    if (refresh != null) {
      settings.refreshOnStart = int.parse(refresh) == 1;
    }
    if (live != null) {
      settings.showLivestreams = int.parse(live) == 1;
    }
    if (movies != null) {
      settings.showMovies = int.parse(movies) == 1;
    }
    if (series != null) {
      settings.showSeries = int.parse(series) == 1;
    }
    if (theme != null) {
      settings.themeMode = AppThemeMode.values[int.parse(theme)];
    }
    return settings;
  }

  static Future<void> updateSettings(Settings settings) async {
    HashMap<String, String> settingsMap = HashMap();
    settingsMap[defaultView] = settings.defaultView.index.toString();
    settingsMap[refreshOnStart] = (settings.refreshOnStart ? 1 : 0).toString();
    settingsMap[showLivestreams] =
        (settings.showLivestreams ? 1 : 0).toString();
    settingsMap[showMovies] = (settings.showMovies ? 1 : 0).toString();
    settingsMap[showSeries] = (settings.showSeries ? 1 : 0).toString();
    settingsMap[themeMode] = settings.themeMode.index.toString();
    await Sql.updateSettings(settingsMap);
  }

  static Future<void> updateLastSeenVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    HashMap<String, String> lastSeenMap = HashMap();
    lastSeenMap[lastSeenVersion] = packageInfo.version;
    await Sql.updateSettings(lastSeenMap);
  }

  static Future<String?> shouldShowWhatsNew() async {
    final String version = (await PackageInfo.fromPlatform()).version;
    return (await Sql.getSettings())[lastSeenVersion] != version
        ? version
        : null;
  }
}
