import 'package:mitril_play/models/media_type.dart';
import 'package:mitril_play/models/view_type.dart';

enum AppThemeMode { light, dark, black }

class Settings {
  ViewType defaultView;
  bool refreshOnStart;
  bool showLivestreams;
  bool showMovies;
  bool showSeries;
  AppThemeMode themeMode;
  Settings(
      {this.defaultView = ViewType.all,
      this.refreshOnStart = false,
      this.showLivestreams = true,
      this.showMovies = true,
      this.showSeries = true,
      this.themeMode = AppThemeMode.dark});

  List<MediaType> getMediaTypes() {
    return [
      if (showLivestreams) MediaType.livestream,
      if (showMovies) MediaType.movie,
      if (showSeries) MediaType.serie
    ];
  }
}
