import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

class TrayService implements TrayListener {
  static final TrayService _instance = TrayService._internal();

  /// Singleton para la bandeja del sistema
  factory TrayService() {
    return _instance;
  }

  TrayService._internal();

  bool _isInitialized = false;

  Future<void> initSystemTray() async {
    try {
      if (_isInitialized) return;

      // Registra como receptor para eventos del system tray
      trayManager.addListener(this);

      // Configura el icono del system tray - probar en otros OS
      final trayIconPath = await _prepareTrayIcon();
      print('Usando ruta de icono de bandeja: $trayIconPath');
      await trayManager.setIcon(trayIconPath);

      await _setupTrayMenu();

      await trayManager.setToolTip('Asistente de Commit Git');

      _isInitialized = true;
      print('Bandeja del sistema inicializada correctamente');
    } catch (e) {
      print('Error al inicializar la bandeja del sistema: $e');
      _isInitialized = false;
    }
  }

  Future<void> _setupTrayMenu() async {
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(
            key: 'show_window',
            label: 'Mostrar Aplicación',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'exit_app',
            label: 'Cerrar',
          ),
        ],
      ),
    );
  }

  void showWindow() async {
    if (await windowManager.isMinimized()) {
      await windowManager.restore();
    }
    await windowManager.show();
    await windowManager.focus();
  }

  void exitApplication() {
    try {
      print('Cerrando aplicación...');
      // Primero destruye el icono de la bandeja
      trayManager.destroy();
      // Luego cierra la aplicación
      exit(0);
    } catch (e) {
      print('Error al cerrar la aplicación: $e');
      // Forzar salida si el cierre normal falla
      exit(1);
    }
  }

  // Implementación de TrayListener
  @override
  void onTrayIconMouseDown() {
    // En Windows, el clic izquierdo normalmente alterna la ventana
    if (Platform.isWindows) {
      showWindow();
    }
  }

  @override
  void onTrayIconMouseUp() {}

  @override
  void onTrayIconRightMouseDown() {
    // Asegura que el menú aparezca al hacer clic derecho (comportamiento de Windows)
    if (Platform.isWindows) {
      trayManager.popUpContextMenu();
    } // TODO:
    else if (Platform.isMacOS) {
      // En macOS, el clic derecho no abre el menú automáticamente
      trayManager.popUpContextMenu();
    } else if (Platform.isLinux) {
      // En Linux, el clic derecho no abre el menú automáticamente
      trayManager.popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseUp() {}

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    print('Elemento del menú de bandeja clickeado: ${menuItem.key}');
    switch (menuItem.key) {
      case 'show_window':
        showWindow();
        break;
      case 'exit_app':
        exitApplication();
        break;
    }
  }

  /// Prepara el icono del system tray según la plataforma
  Future<String> _prepareTrayIcon() async {
    // Para Windows, intenta primero la ruta directa de la plataforma
    if (Platform.isWindows) {
      // Verifica primero la ubicación estándar del icono de Windows
      final String iconPath = path.join(
        Directory.current.path,
        'windows',
        'runner',
        'resources',
        'app_icon.ico',
      );

      if (File(iconPath).existsSync()) {
        print('Usando app_icon.ico de Windows: $iconPath');
        return iconPath;
      }

      // Try the release path - this is critical for release builds
      final execDir = path.dirname(Platform.resolvedExecutable);
      final String releaseIconPath = path.join(
        execDir,
        'data',
        'flutter_assets',
        'assets',
        'icons',
        'app_icon.ico',
      );

      if (File(releaseIconPath).existsSync()) {
        print('Usando app_icon.ico de Windows (release): $releaseIconPath');
        return releaseIconPath;
      }

      print('Iconos no encontrados en rutas estándar.');
    }

    try {
      // Extrae el icono a un archivo temporal para usar con tray_manager
      final ByteData data = await rootBundle.load('assets/icons/app_icon.ico');
      final List<int> bytes = data.buffer.asUint8List();

      // Crea un archivo temporal para almacenar el icono
      final tempDir = await getTemporaryDirectory();
      final iconFile = File(path.join(tempDir.path, 'app_icon.ico'));
      await iconFile.writeAsBytes(bytes);

      print('Icono de bandeja extraído a: ${iconFile.path}');
      return iconFile.path;
    } catch (e) {
      print('Error al preparar el icono de bandeja desde assets: $e');

      // Alternativas específicas de plataforma
      if (Platform.isWindows) {
        // Intentar multiples rutas para el icono de Windows
        final List<String> possiblePaths = [
          // Path with executable directory
          path.join(path.dirname(Platform.resolvedExecutable), 'data',
              'flutter_assets', 'assets', 'icons', 'tray_icon.png'),
          // Direct relative path
          path.join(
              'data', 'flutter_assets', 'assets', 'icons', 'tray_icon.png'),
          // Just in case, try with current directory
          path.join(Directory.current.path, 'data', 'flutter_assets', 'assets',
              'icons', 'tray_icon.png'),

          //test
          path.join(path.dirname(Platform.resolvedExecutable), 'data',
              'flutter_assets', 'assets', 'icons', 'app_icon.ico'),
          path.join(
              'data', 'flutter_assets', 'assets', 'icons', 'app_icon.ico'),
          path.join(Directory.current.path, 'data', 'flutter_assets', 'assets',
              'icons', 'app_icon.ico'),
        ];

        for (final iconPath in possiblePaths) {
          print('Intentando ruta de icono: $iconPath');
          if (File(iconPath).existsSync()) {
            print('Icono encontrado en: $iconPath');
            return iconPath;
          }
        }
      } else if (Platform.isMacOS) {
        // Para macOS, intenta usar el icono de la aplicación
        final String iconPath = path.join(
            Directory.current.path,
            'macos',
            'Runner',
            'Assets.xcassets',
            'AppIcon.appiconset',
            'app_icon_32.png');
        print('Intentando archivo de icono macOS: $iconPath');

        if (File(iconPath).existsSync()) {
          return iconPath;
        }
      } else if (Platform.isLinux) {
        // Para Linux, intenta usar el icono de la aplicación
        final String iconPath = path.join(Directory.current.path, 'linux',
            'flutter', 'icons', 'app_icon.png');
        print('Intentando archivo de icono Linux: $iconPath');

        if (File(iconPath).existsSync()) {
          return iconPath;
        }
      }
      // Última alternativa - simplemente devuelve la ruta del asset
      print('Usando ruta de icono de respaldo desde assets');
      return 'assets/icons/tray_icon.png';
    }
  }
}
