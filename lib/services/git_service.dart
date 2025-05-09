import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';

class GitService {
  /// Verifica si el directorio proporcionado es un repositorio Git
  Future<bool> isGitRepository(String repoPath) async {
    final gitDir = Directory(path.join(repoPath, '.git'));
    return gitDir.existsSync();
  }

  /// Obtiene la lista de archivos modificados en el repositorio Git
  Future<List<String>> getModifiedFiles(String repoPath) async {
    final shell = Shell(workingDirectory: repoPath);
    final result = await shell.run('git status --porcelain');

    final output = result.outText;
    if (output.isEmpty) return [];

    return output
        .split('\n')
        .where((line) => line.startsWith(' M'))
        .map((line) => line.substring(3).trim())
        .toList();
  }

  /// Obtiene la lista de archivos modificados staged (agregados con git add)
  Future<List<String>> getStagedModifiedFiles(String repoPath) async {
    final shell = Shell(workingDirectory: repoPath);
    final result = await shell.run('git status --porcelain');

    final output = result.outText;
    if (output.isEmpty) return [];

    return output
        .split('\n')
        .where((line) => line.startsWith('M ')) // Buscando 'M ' (modificados)
        .map((line) => line.substring(2).trim())
        .toList();
  }

  /// Obtiene la lista de archivos nuevos agregados en el repositorio Git
  Future<List<String>> getAddedFiles(String repoPath) async {
    final shell = Shell(workingDirectory: repoPath);
    final result = await shell.run('git status --porcelain');

    final output = result.outText;
    if (output.isEmpty) return [];

    return output
        .split('\n')
        .where((line) => line.startsWith('A ') || line.startsWith('?? '))
        .map((line) => line.substring(line.startsWith('A ') ? 2 : 3).trim())
        .toList();
  }

  Future<List<String>> getStagedAddedFiles(String repoPath) async {
    final shell = Shell(workingDirectory: repoPath);
    final result = await shell.run('git status --porcelain');

    final output = result.outText;
    if (output.isEmpty) return [];

    return output
        .split('\n')
        .where((line) => line.startsWith('A ')) // Solo 'A ' (agregados)
        .map((line) => line.substring(2).trim())
        .toList();
  }

  /// Obtiene la diferencia de cambios en el repositorio Git
  Future<String> getDiff(String repoPath) async {
    final shell = Shell(workingDirectory: repoPath);
    final result = await shell.run('git diff');

    return result.outText;
  }

  /// Obtiene la diferencia de un archivo específico staged o unstaged
  /// TODO: Agregar soporte para otras opciones de diff
  /// [staged] indica si obtener la diferencia de los cambios preparados
  Future<String> getFileDiff(String repoPath, String filePath,
      {bool staged = false}) async {
    final shell = Shell(workingDirectory: repoPath);
    final command =
        staged ? 'git diff --staged -- "$filePath"' : 'git diff -- "$filePath"';

    final result = await shell.run(command);
    return result.outText;
  }

  /// Obtiene la diferencia de cambios staged en el repositorio Git
  Future<String> getStagedDiff(String repoPath) async {
    final shell = Shell(workingDirectory: repoPath);
    final result = await shell.run('git diff --staged');

    return result.outText;
  }

  /// Obtiene el contenido de un archivo con límite de líneas opcional
  Future<String> getFileContent(String repoPath, String filePath,
      {int? maxLines}) async {
    final file = File(path.join(repoPath, filePath));
    if (!file.existsSync()) {
      return '';
    }

    if (maxLines == null) {
      return file.readAsStringSync();
    }

    try {
      final lines = file.readAsLinesSync();
      final limitedLines = lines.take(maxLines).toList();
      if (lines.length > maxLines) {
        limitedLines.add(
            '... (contenido truncado, mostrando primeras $maxLines líneas)');
      }
      return limitedLines.join('\n');
    } catch (e) {
      return '... (no se pudo leer el contenido del archivo: $e)';
    }
  }
}
