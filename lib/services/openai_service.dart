import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiEndpoint = 'https://api.openai.com/v1/chat/completions';

  /// Genera un mensaje de commit utilizando la API de OpenAI
  Future<String> generateCommitMessage({
    required String apiKey,
    required List<String> modifiedFiles,
    required String diff,
    List<String>? addedFiles,
    Map<String, String> addedFilesContent = const {},
  }) async {
    // Si addedFiles es nulo, asume que todos los archivos en modifiedFiles son modificados
    // Esto maneja el caso donde se pasa la lista combinada
    addedFiles = addedFiles ?? [];

    // Crea listas de archivos para el prompt
    final modifiedFileNames = modifiedFiles.join('\n');
    final addedFileNames = addedFiles.join('\n');

    // Crea el prompt
    String prompt = '''
Genera un título de commit conciso (max. 72 caracteres) siguiendo el formato: <tipo>: <descripción breve>
Donde <tipo> debe ser uno de: feat, fix, docs, style, refactor, test, chore, perf

Después, genera una descripción con viñetas para cada archivo modificado o agregado.
Las descripciones deben ser concisas y enfocarse en el "qué" y el "por qué" del cambio.
IMPORTANTE: Usa SOLO el nombre del archivo (sin rutas/paths).

A partir de estos archivos:
''';

    if (modifiedFiles.isNotEmpty) {
      prompt += '''

ARCHIVOS MODIFICADOS:
$modifiedFileNames

DIFERENCIAS:
$diff
''';
    }

    if (addedFiles.isNotEmpty) {
      prompt += '''

ARCHIVOS AGREGADOS:
$addedFileNames
''';

      if (addedFilesContent.isNotEmpty) {
        prompt += '\n\nCONTENIDO DE ARCHIVOS AGREGADOS:\n';
        addedFilesContent.forEach((file, content) {
          prompt += '''\n
$file:
```
$content
```
''';
        });
      }
    }
// Formato de salida esperado
    prompt += '''
    RESPONDE ÚNICAMENTE CON ESTE FORMATO:
    Titutlo \n
    <TÍTULO>
    Descripcion \n
    <DESCRIPCIÓN EN VIÑETAS>
    ''';
    // Prepara el cuerpo de la solicitud
    final requestBody = {
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'max_tokens': 500,
      'temperature': 0.7,
    };

    // Configura los encabezados
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    try {
      // Realiza la petición a la API
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Analiza la respuesta
        final responseBody = jsonDecode(response.body);
        return responseBody['choices'][0]['message']['content']
            .toString()
            .trim();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API de OpenAI: $e');
    }
  }
}
