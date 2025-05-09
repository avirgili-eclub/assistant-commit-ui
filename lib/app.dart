import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/home_screen.dart';

class CommitAssistantApp extends StatefulWidget {
  const CommitAssistantApp({Key? key}) : super(key: key);

  @override
  State<CommitAssistantApp> createState() => _CommitAssistantAppState();
}

class _CommitAssistantAppState extends State<CommitAssistantApp>
    with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // Maneja el evento de cierre de la ventana
  @override
  Future<void> onWindowClose() async {
    // Previene el cierre de la ventana la oculta en su lugar
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Git Commit Assistant',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  String _apiKey = '';
  String _repoPath = '';
  String _commitMessage = '';
  bool _isLoading = false;

  String get apiKey => _apiKey;
  String get repoPath => _repoPath;
  String get commitMessage => _commitMessage;
  bool get isLoading => _isLoading;

  void setApiKey(String value) {
    _apiKey = value;
    notifyListeners();
  }

  void setRepoPath(String value) {
    _repoPath = value;
    notifyListeners();
  }

  void setCommitMessage(String value) {
    _commitMessage = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
