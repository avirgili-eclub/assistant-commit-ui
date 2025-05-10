# Asistente de Commits Git

Una aplicación de escritorio para generar mensajes de commit estructurados y descriptivos utilizando la API de OpenAI. (proximamente configuracion de otras APIs)

## Descripción
El Asistente de Commits Git analiza los cambios en tu repositorio y utiliza inteligencia artificial para generar mensajes de commit profesionales siguiendo las mejores prácticas. La aplicación detecta archivos modificados y agregados que estén preparados para commit (staged) y produce un mensaje estructurado con un título conciso y descripciones detalladas.

## Características
Generación de mensajes de commit estructurados mediante OpenAI
Análisis de archivos modificados y agregados en repositorios Git
Interfaz gráfica intuitiva y fácil de usar
Funciona como aplicación de escritorio independiente
Soporte para minimizarse a la bandeja del sistema
Compatible con múltiples plataformas (Windows, macOS, Linux)

## Componentes claves

### User Interface Layer
La capa de UI está compuesta por widgets de Flutter que proporcionan user-facing interface para interactuar con la aplicación.

- **CommitAssistantApp** : El root widget de la aplicación que inicializa la app y gestiona las ventanas.
- **HomeScreen** : La interfaz principal donde los usuarios ingresan claves API, seleccionan repositorios y generan mensajes de commit.

### Service Layer
La capa de servicios contiene clases especializadas que manejan las interacciones con sistemas externos:

- **GitService**: Interactúa con repositorios Git para analizar cambios en etapa(staged), obtener diferencias (diffs) y contenidos de archivos.
- **OpenAIService**: Se comunica con la API de OpenAI para generar mensajes de commit.
- **TrayService**: Gestiona la integración con la bandeja del sistema para operaciones en segundo plano.

### State Management
La aplicación utiliza el patrón Provider para gestionar el estado de la aplicación:

- **AppState**: Mantiene el estado global de la aplicación, incluyendo claves API, rutas de repositorios, mensajes de commit generados y estados de carga.

### External Systems
La aplicación interactúa con varios sistemas externos:

- **Repositorio Git**: Repositorios de código fuente gestionados por Git.
- **API de AI**: Servicio de inteligencia artificial utilizado para generar mensajes de commit.
- **Bandeja del Sistema**: Área de notificaciones del sistema operativo para acceso a la aplicación en segundo plano.

## Requisitos previos
- Flutter SDK (v3.29.2 o superior)
- Git instalado en el sistema
- Una clave API de OpenAI

## Instalación

1. Clona este repositorio:
  ```
  git clone https://github.com/avirgili-eclub/assistant-commit-ui.git
  ```
3. Navega al directorio del proyecto:
  ```
  cd assistant-commit-ui  
  ```
3. Instala las dependencias:
  ```
  flutter pub get
  ```
4. Ejecuta la aplicación:
  ```
  flutter run -d windows  # o -d macos o -d linux según tu sistema
  ```

## Uso

1. Inicia la aplicación
2. Ingresa tu clave API de OpenAI en el campo correspondiente
3. Selecciona la ruta de tu repositorio Git utilizando el botón "Explorar"
4. Prepara tus cambios para commit en el repositorio (usando git add)
5. Haz clic en "Analizar y Generar Commit"
6. Copia el mensaje generado para usarlo en tu commit home_screen.dart:143-230

## Tecnologías utilizadas

- Flutter
- OpenAI API (gpt-4o-mini)
- Git
- Material Design

## Licencia
Este proyecto está licenciado bajo la Licencia MIT - vea el archivo [LICENSE](https://raw.githubusercontent.com/avirgili-eclub/assistant-commit-ui/refs/heads/master/LICENSE) para más detalles.
