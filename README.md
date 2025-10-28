
Gestión de Citas
U3. Práctica 1. Control CITAS

Dependencias del Proyecto
Este proyecto utiliza tres librerías principales para gestionar la funcionalidad de mapas y geolocalización.

Instalación
Asegúrate de que estas líneas estén presentes en tu archivo pubspec.yaml:


YAML


dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  geocoding: ^4.0.0
Luego, instala las dependencias ejecutando el siguiente comando en tu terminal:


Bash


flutter pub get

Utilizar los modelos de cita ya que se modifco para el uso de latitudes y longitudes de
Los lugares de las citas

Librerías Utilizadas
Aquí se detalla para qué se usa cada librería en este proyecto:

1. flutter_map 🗺️
Es el paquete principal que dibuja el mapa en la pantalla.

Uso en el código: Proporciona el widget FlutterMap que se usa en la página principal (App02).

Funcionalidad:

Muestra el mapa base de OpenStreetMap (TileLayer).

Dibuja todos los marcadores (verdes y azules) de las citas sobre el mapa (MarkerLayer).

Proporciona el MapController que usamos para centrar la cámara en una cita específica (_moverMapaACita).

2. latlong2 📍
Esta librería es la compañera indispensable de flutter_map. Se encarga de manejar las coordenadas geográficas.

Uso en el código: Proporciona el objeto LatLng.

Funcionalidad:

La usamos para definir el centro inicial del mapa (_centro).

Define la posición exacta de cada Marker en el mapa.

Es el formato que MapController espera para saber a dónde moverse.

3. geocoding 🏠 ➡️ 📍
Esta librería es crucial para la pantalla de "Insertar Cita". Su trabajo es convertir direcciones de texto en coordenadas.

Uso en el código: Se utiliza cuando el usuario selecciona la opción de lugar "Otro".

Funcionalidad:

Toma la calle y la colonia que el usuario escribe (ej: "Av. México" y "Centro").

Llama a la función locationFromAddress(...) para convertir esa dirección de texto en coordenadas LatLng (latitud y longitud).

Esas coordenadas son las que se guardan en la base de datos para que el marcador "Otro" (azul) sepa dónde dibujarse en el mapa.

4. OpenStreetMap (OSM) 🌍
A diferencia de las otras, esta no es una librería de Flutter, sino el proveedor de datos del mapa. Es el servicio que nos da la imagen del mapa mundial.

Uso en el código: Se define como la fuente de imágenes en el TileLayer dentro del widget FlutterMap:

Dart

TileLayer(
  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
  // ...
),
Funcionalidad:

flutter_map (la librería) se conecta a esta URL de OpenStreetMap para descargar las "teselas" (los pequeños cuadros de imagen) que componen el mapa.

Es lo que permite al usuario ver las calles, edificios y geografía del mundo.

Es una alternativa gratuita y de código abierto a otros servicios como Google Maps, y no requiere una API Key (llave de acceso) para este tipo de uso.
