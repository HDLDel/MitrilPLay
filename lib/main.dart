import 'dart:io';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:logging/logging.dart';
import 'package:mitril_play/backend/settings_service.dart';
import 'package:mitril_play/backend/sql.dart';
import 'package:mitril_play/home.dart';
import 'package:mitril_play/models/filters.dart';
import 'package:mitril_play/models/home_manager.dart';
import 'package:mitril_play/models/settings.dart';
import 'package:mitril_play/setup.dart';
import 'package:mitril_play/theme.dart';

final _logger = Logger('App');

Future<void> main() async {
  // Run in a custom zone to catch all async errors
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      MediaKit.ensureInitialized();
    } catch (e) {
      // Ignora erro se o libmpv não estiver presente no sistema.
      // O app continuará e usará os players externos de fallback.
      debugPrint('Aviso: Falha ao inicializar o MediaKit (provavelmente libmpv não instalado): $e');
    }

    // Setup logging
    _setupGlobalLogging();
    _logger.info('App starting...');
    
    try {
      _logger.info('Checking for sources...');
      final hasSources = await Sql.hasSources();
      _logger.info('Has sources: $hasSources');
      
      _logger.info('Loading settings...');
      final settings = await SettingsService.getSettings();
      _logger.info('Settings loaded: defaultView=${settings.defaultView}');

      _logger.info('Starting app');
      runApp(MyApp(
        skipSetup: hasSources,
        settings: settings,
      ));
    } catch (e, stackTrace) {
      _logger.severe('Fatal error during startup: $e', e, stackTrace);
      rethrow;
    }
  }, (error, stackTrace) {
    // This catches ALL unhandled async errors in the app
    _logger.severe('UNCAUGHT ASYNC ERROR: $error', error, stackTrace);
    // Don't crash - just log and continue
  });
}

void _setupGlobalLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // Log para console
    debugPrint('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
      debugPrint('StackTrace: ${record.stackTrace}');
    }

    // Log para arquivo (Windows)
    if (kReleaseMode && Platform.isWindows) {
      _logToFile(record);
    }
  });

  // Capturar erros globais do Flutter - NÃO fechar o app
  FlutterError.onError = (details) {
    _logger.severe('Flutter error: ${details.summary}', details.exception, details.stack);
    // Mostrar error widget customizado em vez de crashar
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _logger.severe('Platform error: $error', error, stack);
    // Retornar true para NÃO fechar o app
    return true;
  };
  
  // Error widget builder customizado
  ErrorWidget.builder = (FlutterErrorDetails details) {
    _logger.severe('UI Error: ${details.exception}', details.exception, details.stack);
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Erro: ${details.exception}',
              style: const TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'O app continua funcionando.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  };
}

void _logToFile(LogRecord record) {
  // Implementação simples de log para arquivo
  final logPath = '${Platform.environment['APPDATA'] ?? '.'}\\MitrilPlay\\logs\\app.log';
  final dir = File(logPath).parent;
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  
  final logLine = '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}\n';
  File(logPath).writeAsStringSync(logLine, mode: FileMode.append);
  
  if (record.error != null || record.stackTrace != null) {
    File(logPath).writeAsStringSync('Error: ${record.error}\nStack: ${record.stackTrace}\n\n', mode: FileMode.append);
  }
}

class MyApp extends StatelessWidget {
  final bool skipSetup;
  final Settings settings;
  const MyApp({super.key, required this.skipSetup, required this.settings});

  @override
  Widget build(BuildContext context) {
    // Define o tema baseado na configuração
    ThemeData currentTheme = getThemeByMode(settings.themeMode);
    ThemeData darkTheme = createDarkTheme();

    return MaterialApp(
        title: 'MitrilPlay',
        theme: currentTheme,
        darkTheme: darkTheme,
        themeMode: settings.themeMode == AppThemeMode.light
            ? ThemeMode.light
            : ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: skipSetup
            ? Home(
                firstLaunch: true,
                refresh: settings.refreshOnStart,
                home: HomeManager(
                    filters: Filters(
                  viewType: settings.defaultView,
                )))
            : const Setup());
  }
}
