import 'package:flutter/material.dart';
import 'package:mitril_play/backend/settings_service.dart';
import 'package:mitril_play/backend/sql.dart';
import 'package:mitril_play/backend/utils.dart';
import 'package:mitril_play/side_nav.dart';
import 'package:mitril_play/confirm_delete.dart';
import 'package:mitril_play/models/filters.dart';
import 'package:mitril_play/select_dialog.dart';
import 'package:mitril_play/edit_dialog.dart';
import 'package:mitril_play/home.dart';
import 'package:mitril_play/loading.dart';
import 'package:mitril_play/models/home_manager.dart';
import 'package:mitril_play/models/id_data.dart';
import 'package:mitril_play/models/settings.dart';
import 'package:mitril_play/models/source.dart';
import 'package:mitril_play/models/source_type.dart';
import 'package:mitril_play/models/view_type.dart';
import 'package:mitril_play/error.dart';
import 'package:mitril_play/setup.dart';
import 'package:mitril_play/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class _ThemePreviewColors {
  final Color card;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color border;
  final Color text;

  _ThemePreviewColors({
    required this.card,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.border,
    required this.text,
  });
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsView> {
  Settings settings = Settings();
  List<Source> sources = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    var results =
        await Future.wait([SettingsService.getSettings(), Sql.getSources()]);
    setState(() {
      settings = results[0] as Settings;
      sources = results[1] as List<Source>;
      loading = false;
    });
  }

  void updateView(ViewType view) {
    if (view != ViewType.settings) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              Home(home: HomeManager(filters: Filters(viewType: view))),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        ),
        (route) => false,
      );
    }
  }

  Future<void> showEditDialog(BuildContext context, final Source source) async {
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (builder) =>
            EditDialog(source: source, afterSave: reloadSources));
  }

  Future<void> _showDefaultViewDialog(BuildContext context) async {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return SelectDialog(
              title: "Default view",
              data: ViewType.values
                  .take(4)
                  .map((x) => IdData(id: x.index, data: x.name))
                  .toList(),
              action: (view) {
                setState(() {
                  settings.defaultView = ViewType.values[view];
                  updateSettings();
                });
                Navigator.of(context).pop();
              });
        });
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Escolha um Tema'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: AppThemeMode.values.map((mode) {
                  final isSelected = settings.themeMode == mode;
                  final themeColors = _getThemePreviewColors(mode);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        settings.themeMode = mode;
                        updateSettings();
                      });
                      Navigator.of(context).pop();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: themeColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? themeColors.primary : themeColors.border,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: themeColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Preview circles
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: themeColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: themeColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: themeColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Icon
                          Icon(
                            themeModeToIcon(mode),
                            color: themeColors.primary,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          // Name
                          Text(
                            _getThemeName(mode),
                            style: TextStyle(
                              color: themeColors.text,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.check_circle,
                                color: themeColors.primary,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          );
        });
  }

  _ThemePreviewColors _getThemePreviewColors(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return _ThemePreviewColors(
          card: Colors.white,
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF818CF8),
          accent: const Color(0xFFA78BFA),
          border: const Color(0xFFE5E7EB),
          text: const Color(0xFF111827),
        );
      case AppThemeMode.dark:
        return _ThemePreviewColors(
          card: ThemeColors.darkCard,
          primary: ThemeColors.darkPrimary,
          secondary: ThemeColors.darkSecondary,
          accent: ThemeColors.darkAccent,
          border: ThemeColors.darkBorder,
          text: ThemeColors.darkText,
        );
      case AppThemeMode.black:
        return _ThemePreviewColors(
          card: const Color(0xFF0A0A0A),
          primary: ThemeColors.darkPrimary,
          secondary: ThemeColors.darkSecondary,
          accent: ThemeColors.darkAccent,
          border: const Color(0xFF1A1A1A),
          text: ThemeColors.darkText,
        );
      case AppThemeMode.aurora:
        return _ThemePreviewColors(
          card: ThemeColors.auroraCard,
          primary: ThemeColors.auroraPrimary,
          secondary: ThemeColors.auroraSecondary,
          accent: ThemeColors.auroraAccent,
          border: ThemeColors.auroraBorder,
          text: ThemeColors.auroraText,
        );
      case AppThemeMode.cosmic:
        return _ThemePreviewColors(
          card: ThemeColors.cosmicCard,
          primary: ThemeColors.cosmicPrimary,
          secondary: ThemeColors.cosmicSecondary,
          accent: ThemeColors.cosmicAccent,
          border: ThemeColors.cosmicBorder,
          text: ThemeColors.cosmicText,
        );
      case AppThemeMode.ocean:
        return _ThemePreviewColors(
          card: ThemeColors.oceanCard,
          primary: ThemeColors.oceanPrimary,
          secondary: ThemeColors.oceanSecondary,
          accent: ThemeColors.oceanAccent,
          border: ThemeColors.oceanBorder,
          text: ThemeColors.oceanText,
        );
    }
  }

  String _getThemeName(AppThemeMode mode) {
    return themeModeToString(mode);
  }

  Future<void> toggleSource(Source source) async {
    await Error.tryAsyncNoLoading(
        () async => await Sql.setSourceEnabled(!source.enabled, source.id!),
        context);
    await reloadSources();
  }

  Widget getSource(Source source) {
    return Card(
        margin: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5), // Spacing around the tile
        elevation: 5,
        color: source.enabled
            ? Theme.of(context).colorScheme.surfaceContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ListTile(
          onLongPress: () => toggleSource(source),
          contentPadding: const EdgeInsets.only(left: 20),
          title: Text(source.name),
          subtitle: Text(getSourceTypeString(source.sourceType)),
          trailing: Row(
            mainAxisSize:
                MainAxisSize.min, // Ensures the row takes up minimal space
            children: [
              Offstage(
                  offstage: source.sourceType == SourceType.m3u,
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await Error.tryAsync(() async {
                        await Utils.refreshSource(source);
                      }, context, "Source has been refreshed successfully");
                    },
                  )),
              Offstage(
                  offstage: source.sourceType == SourceType.m3u,
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async =>
                        await showEditDialog(context, source),
                  )),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async => await showConfirmDeleteDialog(source),
              ),
            ],
          ),
        ));
  }

  Future<void> showConfirmDeleteDialog(Source source) async {
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (builder) => ConfirmDelete(
            type: "source",
            name: source.name,
            confirm: () async {
              await Error.tryAsync(
                  () async => await Sql.deleteSource(source.id!),
                  context,
                  "Successfully deleted source");
              await reloadSources();
              if (sources.isEmpty) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Setup()),
                    (route) => false);
              }
            }));
  }

  Future<void> reloadSources() async {
    await Error.tryAsyncNoLoading(
        () async => sources = await Sql.getSources(), context);
    setState(() {
      sources;
    });
  }

  Future<void> updateSettings() async {
    await Error.tryAsyncNoLoading(
        () async => await SettingsService.updateSettings(settings), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNav(
            updateViewMode: updateView,
            startingView: ViewType.settings,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Visibility(
              visible: !loading,
              child: Loading(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
                    child: ListView(
                      children: [
                        const SizedBox(height: 10),
                        const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('Settings',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(height: 10),
                        ListTile(
                            title: const Text("Donate"),
                            subtitle: const Text(
                                "MitrilPlay needs your help! Consider donating ❤️"),
                            onTap: () async => await launchUrl(
                                Uri.parse(
                                  "https://github.com/Fredolx/open-tv-mobile/discussions/1",
                                ),
                                mode: LaunchMode.externalApplication)),
                        ListTile(
                            title: const Text("Default view"),
                            subtitle:
                                Text(viewTypeToString(settings.defaultView)),
                            onTap: () async =>
                                await _showDefaultViewDialog(context)),
                        ListTile(
                            title: const Text("Theme"),
                            subtitle:
                                Text(themeModeToString(settings.themeMode)),
                            onTap: () async =>
                                await _showThemeDialog(context)),
                        ListTile(
                          title: const Text("Refresh sources on start"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: settings.refreshOnStart,
                                onChanged: (bool value) {
                                  setState(() {
                                    settings.refreshOnStart = value;
                                  });
                                  updateSettings();
                                },
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: const Text("Show livestreams"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: settings.showLivestreams,
                                onChanged: (bool value) {
                                  setState(() {
                                    settings.showLivestreams = value;
                                  });
                                  updateSettings();
                                },
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: const Text("Show movies"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: settings.showMovies,
                                onChanged: (bool value) {
                                  setState(() {
                                    settings.showMovies = value;
                                  });
                                  updateSettings();
                                },
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: const Text("Show series"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: settings.showSeries,
                                onChanged: (bool value) {
                                  setState(() {
                                    settings.showSeries = value;
                                  });
                                  updateSettings();
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text('Sources',
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold))),
                              Row(children: [
                                IconButton(
                                    onPressed: () async => await Error.tryAsync(
                                        () async =>
                                            await Utils.refreshAllSources(),
                                        context,
                                        "Successfully refreshed all sources"),
                                    icon: const Icon(Icons.refresh)),
                                IconButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Setup(
                                                  showAppBar: true,
                                                ))),
                                    icon: const Icon(Icons.add))
                              ])
                            ]),
                        const SizedBox(height: 10),
                        ...sources.map(getSource)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
