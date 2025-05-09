import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'services/tray_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el WindowsManager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: "Git Commit Assistant",
    windowButtonVisibility: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(
        true); // Previene que se cierre para que vaya a system tray
    await windowManager.show();
    await windowManager.focus();
  });

  // Inicializa el SystemTray
  final trayService = TrayService();
  await trayService.initSystemTray();

  runApp(const CommitAssistantApp());

  // For Windows: configure window frame
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      const initialSize = Size(800, 600);
      appWindow.minSize = const Size(600, 450);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  } else if (Platform.isMacOS) {
    appWindow.minSize = const Size(600, 450);
    appWindow.size = const Size(800, 600);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  } else if (Platform.isLinux) {
    appWindow.minSize = const Size(600, 450);
    appWindow.size = const Size(800, 600);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  }
}
