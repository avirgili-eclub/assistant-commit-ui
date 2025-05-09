import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';
import '../app.dart';
import '../services/git_service.dart';
import '../services/openai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  final GitService _gitService = GitService();
  final OpenAIService _openAIService = OpenAIService();
  final _apiKeyController = TextEditingController();
  final _repoPathController = TextEditingController();
  final _outputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _apiKeyController.dispose();
    _repoPathController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  // Maneja el evento de cierre de ventana - oculta en lugar de cerrar
  @override
  void onWindowClose() async {
    // Oculta la ventana en lugar de cerrar la aplicación
    await windowManager.hide();

    // Muestra una notificación de que la aplicación sigue ejecutándose en la bandeja
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aplicación minimizada a la bandeja del sistema'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loadSavedData() async {
    // Aquí podrías implementar la carga de la clave API guardada desde almacenamiento seguro
  }

  Future<void> _browseRepo() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      print('Nueva ruta seleccionada: $selectedDirectory');
      setState(() {
        _repoPathController.text = selectedDirectory;
      });
      Provider.of<AppState>(
        context,
        listen: false,
      ).setRepoPath(selectedDirectory);
    }
  }

  Future<void> _analyzeAndGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final apiKey = _apiKeyController.text;
    final repoPath = _repoPathController.text;

    appState.setApiKey(apiKey);
    appState.setRepoPath(repoPath);
    appState.setLoading(true);

    try {
      // Verifica si el directorio es un repositorio Git
      if (!await _gitService.isGitRepository(repoPath)) {
        _showError('La ruta seleccionada no es un repositorio Git válido.');
        appState.setLoading(false);
        return;
      }

      // Obtiene archivos modificados preparados
      final modifiedFiles = await _gitService.getStagedModifiedFiles(repoPath);

      // Obtiene archivos agregados preparados
      final addedFiles = await _gitService.getStagedAddedFiles(repoPath);

      if (modifiedFiles.isEmpty && addedFiles.isEmpty) {
        _showInfo(
            'No se encontraron archivos preparados para commit. Asegúrate de usar git add primero.');
        appState.setLoading(false);
        return;
      }

      // Obtiene diferencias de cambios preparados
      final diff = await _gitService.getStagedDiff(repoPath);

      // Genera mensaje de commit usando OpenAI - pasa ambas listas por separado
      final commitMessage = await _openAIService.generateCommitMessage(
        apiKey: apiKey,
        modifiedFiles: modifiedFiles,
        diff: diff,
        addedFiles: addedFiles,
      );

      setState(() {
        _outputController.text = commitMessage;
      });
      appState.setCommitMessage(commitMessage);
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      appState.setLoading(false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente de Commits'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // API Key input
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'Clave API de OpenAI',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.visibility_off),
                    onPressed: () {},
                    tooltip: 'Clave API oculta',
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la clave API';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Repository path input with browse button
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _repoPathController,
                      decoration: InputDecoration(
                        labelText: 'Ruta del Repositorio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, seleccione la ruta del repositorio';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _browseRepo,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Explorar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Analyze and generate button
              ElevatedButton.icon(
                onPressed: appState.isLoading ? null : _analyzeAndGenerate,
                icon: appState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics),
                label: Text(
                  appState.isLoading
                      ? 'Analizando...'
                      : 'Analizar y Generar Commit',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Output text field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mensaje de Commit Generado:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          TextField(
                            controller: _outputController,
                            maxLines: null,
                            expands: true,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                            ),
                          ),
                          if (_outputController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copiar al portapapeles',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _outputController.text),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copiado al portapapeles'),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
