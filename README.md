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

## Requisitos previos
Flutter SDK (v3.29.2 o superior)
Git instalado en el sistema
Una clave API de OpenAI

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
