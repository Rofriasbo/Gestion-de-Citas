import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:agenda/basedatosforaneas.dart';
import 'package:agenda/persona.dart';
import 'package:agenda/cita.dart';

const Color _primaryColor = Colors.teal;

const List<Map<String, dynamic>> kLugaresFijos = [
  {'nombre': 'Casino Vegas', 'lat': 21.5050, 'lon': -104.8950},
  {'nombre': 'Finca Los Abuelos', 'lat': 21.5130, 'lon': -104.8810},
  {'nombre': 'QM Eventos', 'lat': 21.4980, 'lon': -104.8920},
  {'nombre': 'Hotel Real de Don Juan', 'lat': 21.5080, 'lon': -104.8956},
  {'nombre': 'Salón Campestre La Noria', 'lat': 21.5230, 'lon': -104.9095},
  {'nombre': 'Restaurante Loma 42', 'lat': 21.5145, 'lon': -104.9002},
  {'nombre': 'Rest. La Cierrita', 'lat': 21.275678162531747, 'lon': -104.64880399733745},
  {'nombre': 'Rest. La Casa de Don Lauro', 'lat': 21.42649177844808, 'lon': -104.89945909574315},
  {'nombre': 'Rest. El Borrego de la Z', 'lat': 21.335044464384154, 'lon': -104.6768339256815},
  {'nombre': 'Wippiz Plaza La Loma', 'lat': 21.5142, 'lon': -104.8985},
  {'nombre': 'Hacienda de Cacao', 'lat': 21.4635, 'lon': -104.9011},
  {'nombre': 'Salón de Eventos El Solar', 'lat': 21.4682, 'lon': -104.8974},
  {'nombre': 'Restaurante Muul', 'lat': 21.3325, 'lon': -104.5820},
  {'nombre': 'Parador La Laguna', 'lat': 21.3340, 'lon': -104.5815},
  {'nombre': 'Playa Matanchen', 'lat': 21.5308, 'lon': -105.2472},
  {'nombre': 'Hotel Garza Canela (Rest. El Delfin)', 'lat': 21.5385, 'lon': -105.2845},
  {'nombre': 'Muelle de San Blas', 'lat': 21.5397, 'lon': -105.2856},
];

final Map<String, LatLng> kLugaresFijosMap = {
  for (var lugar in kLugaresFijos)
    lugar['nombre'] as String: LatLng(lugar['lat'] as double, lugar['lon'] as double)
};

const String kOpcionOtro = "Otro";

const List<String> kColoniasTepic = <String>[
  'Centro',
  'Ciudad del Valle',
  'Mololoa',
  'San Juan',
  'Fray Junípero Serra',
  'Llanitos',
  'Las Flores',
  'Emilio M. González',
  'Los Fresnos',
];

final Map<String, List<String>> kCallesPorColonia = {
  'centro': ['Av. México', 'Zacatecas', 'Puebla', 'Lerdo', 'Hidalgo', 'Morelos', 'Zapata'],
  'ciudad del valle': ['Av. Insurgentes', 'Brasil', 'Argentina', 'Colombia', 'Av. del Valle', 'Alaska'],
  'mololoa': ['Av. Victoria', 'Pedraza', 'Río Suchiate', 'Río Mololoa'],
  'san juan': ['Av. Jacarandas', 'Encino', 'Roble', 'Cedro', 'Álamo'],
};

InputDecoration _buildInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );
}

final ButtonStyle _mainButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: _primaryColor,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
);

final ButtonStyle _deleteButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.red[700],
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
);


class App02 extends StatefulWidget {
  const App02({super.key});

  @override
  State<App02> createState() => _App02State();
}

class _App02State extends State<App02> {
  final LatLng _centro = const LatLng(21.5050, -104.8950);
  List<Marker> _marcadores = [];
  final MapController _mapController = MapController();

  final String _appVersion = "1.0.0"; // Variable ahora declarada

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }



  Future<void> _cargarCitas() async {
    List<Marker> marcadoresTemporales = [];
    List<Map<String, dynamic>> todasLasCitas = [];

    try {
      todasLasCitas = await DB.mostrarCitasConPersona();
    } catch (e) {
      debugPrint("Error al cargar citas: $e");
    }

    final Set<String> nombresLugaresFijos = kLugaresFijos.map((l) => l['nombre'] as String).toSet();

    for (var lugar in kLugaresFijos) {
      final String nombreLugar = lugar['nombre'];
      final List<Map<String, dynamic>> citasEnEsteLugar = todasLasCitas
          .where((cita) => cita['LUGAR'] == nombreLugar)
          .toList();

      marcadoresTemporales.add(
        Marker(
          point: LatLng(lugar['lat'], lugar['lon']),
          width: 80, height: 80,
          child: GestureDetector(
            onTap: () => _mostrarInfoLugar(context, nombreLugar, citasEnEsteLugar),
            child: const Icon(Icons.location_pin, color: Colors.green, size: 40),
          ),
        ),
      );
    }

    final marcadoresCitasOtras = todasLasCitas
        .where((cita) => !nombresLugaresFijos.contains(cita['LUGAR']))
        .map((cita) {
      final dynamic rawLat = cita['LATITUD'];
      final dynamic rawLon = cita['LONGITUD'];
      final double lat = rawLat is num ? rawLat.toDouble() : double.tryParse(rawLat?.toString() ?? '') ?? _centro.latitude;
      final double lon = rawLon is num ? rawLon.toDouble() : double.tryParse(rawLon?.toString() ?? '') ?? _centro.longitude;

      return Marker(
        point: LatLng(lat, lon),
        width: 80, height: 80,
        child: Tooltip(
          message: "Lugar: ${cita['LUGAR']}\nPersona: ${cita['NOMBRE_PERSONA']}\nHora: ${cita['HORA'] ?? 'No definida'}",
          child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
        ),
      );
    });

    marcadoresTemporales.addAll(marcadoresCitasOtras);

    if (mounted) {
      setState(() { _marcadores = marcadoresTemporales; });
    }
  }

  void _mostrarInfoLugar(BuildContext context, String nombreLugar, List<Map<String, dynamic>> citas) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombreLugar,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Divider(thickness: 0.5),
              const SizedBox(height: 12),
              Text(
                "Citas Programadas",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              if (citas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: Text("No hay citas programadas aquí.")),
                ),

              if (citas.isNotEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: citas.length,
                    itemBuilder: (context, index) {
                      final cita = citas[index];
                      final fecha = cita['FECHA'] ?? 'Sin fecha';
                      final hora = cita['HORA'] ?? 'Sin hora';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _primaryColor.withOpacity(0.1),
                          foregroundColor: _primaryColor,
                          child: const Icon(Icons.person_outline, size: 20),
                        ),
                        title: Text(cita['NOMBRE_PERSONA'] ?? 'Desconocido'),
                        subtitle: Text("$fecha - $hora"),
                        dense: true,
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _moverMapaACita(Map<String, dynamic> cita) {
    double lat = _centro.latitude;
    double lon = _centro.longitude;
    final String? lugarNombre = cita['LUGAR'];
    final lugarFijo = kLugaresFijos.firstWhere((l) => l['nombre'] == lugarNombre, orElse: () => {});

    if (lugarFijo.isNotEmpty) {
      lat = lugarFijo['lat'];
      lon = lugarFijo['lon'];
    } else {
      final dynamic rawLat = cita['LATITUD'];
      final dynamic rawLon = cita['LONGITUD'];
      lat = rawLat is num ? rawLat.toDouble() : double.tryParse(rawLat?.toString() ?? '') ?? _centro.latitude;
      lon = rawLon is num ? rawLon.toDouble() : double.tryParse(rawLon?.toString() ?? '') ?? _centro.longitude;
    }
    _mapController.move(LatLng(lat, lon), 16.0);
  }

  Future<void> _mostrarConfirmacionRecursos() async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Recursos Técnicos"),
          content: const Text("¿Desea ingresar a los recursos técnicos?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: _primaryColor), // Color primario para aceptar
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );

    if (confirmado == true && mounted) {
      _mostrarDialogoRecursosTecnicos();
    }
  }

  void _mostrarDialogoRecursosTecnicos() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Información Técnica"),
          content: SingleChildScrollView( // Para asegurar que quepa en pantallas pequeñas
            child: ListBody(
              children: <Widget>[
                const Text("Versión de la App:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_appVersion), // Usando la variable _appVersion
                const SizedBox(height: 10),
                const Text("APIs/Paquetes Utilizados:", style: TextStyle(fontWeight: FontWeight.bold)),
                const Text("- flutter_map (Mapas)"),
                const Text("- geocoding (Conversión Dirección <-> Coordenadas)"),
                const Text("- latlong2 (Manejo de Coordenadas)"),
                const Text("- sqflite (Base de Datos Local - asumido)"),
                const SizedBox(height: 10),
                const Text("Fuente de Datos del Mapa:", style: TextStyle(fontWeight: FontWeight.bold)),
                const Text("- OpenStreetMap (Teselas del mapa)"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AGENDA"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        elevation: 1,
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.map_outlined,
                          size: 30,
                          color: _primaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Gestor de Agenda",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const Icon(Icons.people_alt_outlined, color: Colors.black54),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: const Text("Personas", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  iconColor: _primaryColor,
                  collapsedIconColor: Colors.black54,
                  childrenPadding: const EdgeInsets.only(left: 36),
                  children: [
                    _buildDrawerItem(Icons.person_add_alt_1_outlined, "Insertar persona", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const InsertarPersonaPage()))
                          .then((_) => _cargarCitas());
                    }),
                    _buildDrawerItem(Icons.list_alt_outlined, "Mostrar personas", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MostrarPersonasPage()));
                    }),
                    _buildDrawerItem(Icons.person_remove_outlined, "Eliminar persona", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EliminarPersonaPage()));
                    }),
                  ],
                ),
              ),

              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const Icon(Icons.calendar_today_outlined, color: Colors.black54),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: const Text("Citas", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  iconColor: _primaryColor,
                  collapsedIconColor: Colors.black54,
                  childrenPadding: const EdgeInsets.only(left: 36),
                  children: [
                    _buildDrawerItem(Icons.add_box_outlined, "Insertar cita", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const InsertarCitaPage()))
                          .then((_) => _cargarCitas());
                    }),
                    _buildDrawerItem(Icons.event_available_outlined, "Mostrar citas", () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MostrarCitasPage()),
                      );
                      if (result != null && result is Map<String, dynamic> && mounted) {
                        _moverMapaACita(result);
                      }
                    }, closeDrawerFirst: false),
                    _buildDrawerItem(Icons.delete_sweep_outlined, "Eliminar cita", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EliminarCitaPage()));
                    }),
                  ],
                ),
              ),

              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const Icon(Icons.help_outline_outlined, color: Colors.black54),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: const Text("Manual de Usuario", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  iconColor: _primaryColor,
                  collapsedIconColor: Colors.black54,
                  childrenPadding: const EdgeInsets.only(left: 36),
                  children: [
                    _buildDrawerItem(Icons.location_on_outlined, "Agregar Lugares", () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ayuda: Agrega lugares fijos o usa 'Otro'."), duration: Duration(seconds: 2))
                      );
                    }),
                    _buildDrawerItem(Icons.edit_calendar_outlined, "Crear/Editar Citas", () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ayuda: Usa los formularios para gestionar citas."), duration: Duration(seconds: 2))
                      );
                    }),
                    _buildDrawerItem(Icons.map_outlined, "Navegar el Mapa", () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ayuda: Toca marcadores o usa 'Mostrar Citas' para ir a ubicaciones."), duration: Duration(seconds: 3))
                      );
                    }),
                    _buildDrawerItem(Icons.delete_outline, "Eliminar Registros", () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ayuda: Usa las opciones de eliminar con precaución."), duration: Duration(seconds: 2))
                      );
                    }),
                    _buildDrawerItem(Icons.code_outlined, "Recursos Técnicos", () {
                      _mostrarConfirmacionRecursos(); // Llama a la función del diálogo
                    }),
                  ],
                ),
              ),

              const Divider(indent: 20, endIndent: 20, height: 20),

              _buildDrawerItem(Icons.refresh_outlined, "Recargar mapa", () {
                _cargarCitas();
              }),
              _buildDrawerItem(Icons.logout_outlined, "Salir", () {
                // Lógica de salida
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _centro,
          initialZoom: 13,
          maxZoom: 18,
          minZoom: 3,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b','c'],
          ),
          MarkerLayer(markers: _marcadores),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool closeDrawerFirst = true}) {
    return ListTile(
      leading: Icon(icon, size: 22, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontSize: 14.5)),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      visualDensity: VisualDensity.compact,
      onTap: () {
        if (closeDrawerFirst) {
          Navigator.pop(context);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onTap();
        });
      },
    );
  }
}

// =========================================================================
// =================== PÁGINAS DE PERSONAS =================================
// =========================================================================

class InsertarPersonaPage extends StatefulWidget {
  final Persona? personaAEditar;

  const InsertarPersonaPage({super.key, this.personaAEditar});

  @override
  State<InsertarPersonaPage> createState() => _InsertarPersonaPageState();
}

class _InsertarPersonaPageState extends State<InsertarPersonaPage> {
  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _esEdicion = false;

  @override
  void initState() {
    super.initState();
    if (widget.personaAEditar != null) {
      _esEdicion = true;
      nombreCtrl.text = widget.personaAEditar!.nombre;
      telefonoCtrl.text = widget.personaAEditar!.telefono;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? "Modificar Persona" : "Insertar Persona"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreCtrl,
                decoration: _buildInputDecoration("Nombre"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefonoCtrl,
                decoration: _buildInputDecoration("Teléfono"),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: _mainButtonStyle,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    if (_esEdicion) {
                      final p = Persona(
                          idpersona: widget.personaAEditar!.idpersona,
                          nombre: nombreCtrl.text,
                          telefono: telefonoCtrl.text
                      );
                      await DB.actualizarPersona(p);
                      if(mounted) ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("Persona actualizada")));
                    } else {
                      final p = Persona(nombre: nombreCtrl.text, telefono: telefonoCtrl.text);
                      await DB.insertarPersona(p);
                      if(mounted) ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("Persona insertada")));
                    }
                    if(mounted) Navigator.pop(context);
                  }
                },
                child: Text(_esEdicion ? "Actualizar" : "Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MostrarPersonasPage extends StatefulWidget {
  const MostrarPersonasPage({super.key});

  @override
  State<MostrarPersonasPage> createState() => _MostrarPersonasPageState();
}

class _MostrarPersonasPageState extends State<MostrarPersonasPage> {
  late Future<List<Persona>> _futurePersonas;

  @override
  void initState() {
    super.initState();
    _futurePersonas = DB.mostrarPersonas();
  }

  void _recargarPersonas() {
    setState(() {
      _futurePersonas = DB.mostrarPersonas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futurePersonas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Personas"),
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Personas"),
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: Text("No hay personas registradas.")),
          );
        }

        final personas = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Personas"),
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: personas.length,
            itemBuilder: (_, i) {
              final p = personas[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: ListTile(
                  leading: const Icon(Icons.person, color: _primaryColor),
                  title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Tel: ${p.telefono}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: _primaryColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InsertarPersonaPage(personaAEditar: p),
                        ),
                      ).then((_) => _recargarPersonas());
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class EliminarPersonaPage extends StatefulWidget {
  const EliminarPersonaPage({super.key});

  @override
  State<EliminarPersonaPage> createState() => _EliminarPersonaPageState();
}

class _EliminarPersonaPageState extends State<EliminarPersonaPage> {
  List<Persona> _personas = [];
  int? _selectedPersonaId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPersonas();
  }

  Future<void> _cargarPersonas() async {
    setState(() { _isLoading = true; });
    final personas = await DB.mostrarPersonas();
    if (mounted) {
      setState(() {
        _personas = personas;
        _isLoading = false;
      });
    }
  }

  Future<bool> _mostrarDialogoConfirmacion() async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Está seguro de que desea eliminar a esta persona?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
    return confirmado ?? false;
  }

  void _eliminarPersona() async {
    if (_selectedPersonaId == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, seleccione una persona.")),
      );
      return;
    }

    final bool confirmado = await _mostrarDialogoConfirmacion();

    if (confirmado) {
      try {
        await DB.eliminarPersona(_selectedPersonaId!);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Persona eliminada")),
        );
        setState(() {
          _selectedPersonaId = null;
        });
        _cargarPersonas();
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al eliminar. Asegúrese de que la persona no tenga citas asociadas.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eliminar Persona"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              DropdownButtonFormField<int>(
                value: _selectedPersonaId,
                hint: const Text("Seleccione una persona"),
                decoration: _buildInputDecoration("Persona a eliminar"),
                items: _personas.map((persona) {
                  return DropdownMenuItem<int>(
                    value: persona.idpersona,
                    child: Text(persona.nombre),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _selectedPersonaId = valor;
                  });
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _eliminarPersona,
              style: _deleteButtonStyle,
              child: const Text("Eliminar"),
            )
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// =================== PÁGINAS DE CITAS ====================================
// =========================================================================

class InsertarCitaPage extends StatefulWidget {
  final Map<String, dynamic>? citaAEditar;

  const InsertarCitaPage({super.key, this.citaAEditar});
  @override
  State<InsertarCitaPage> createState() => _InsertarCitaPageState();
}

class _InsertarCitaPageState extends State<InsertarCitaPage> {
  final lugarCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();
  final horaCtrl = TextEditingController();
  final anotacionesCtrl = TextEditingController();
  final coloniaOtroCtrl = TextEditingController();
  final calleOtroCtrl = TextEditingController();
  final entreCalleOtroCtrl = TextEditingController();

  List<Map<String, dynamic>> _personas = [];
  int? _idPersonaSeleccionada;
  String? _lugarSeleccionado = kLugaresFijos.first['nombre'];
  String? _coloniaSeleccionada;
  String? _calleSeleccionada;
  String? _entreCalleSeleccionada;
  List<String> _callesDisponibles = [kOpcionOtro];
  List<String> _entreCallesDisponibles = [kOpcionOtro];


  final _formKey = GlobalKey<FormState>();
  final LatLng _defaultCoords = const LatLng(21.5050, -104.8950);
  bool _esEdicion = false;
  bool _isSaving = false;

  DateTime _initialDate = DateTime.now();
  final TimeOfDay _initialTime = TimeOfDay.now();


  @override
  void initState() {
    super.initState();
    _cargarPersonas();

    if (widget.citaAEditar != null) {
      _esEdicion = true;
      final cita = widget.citaAEditar!;
      final String lugar = cita['LUGAR'] ?? '';

      if (kLugaresFijosMap.containsKey(lugar)) {
        _lugarSeleccionado = lugar;
      } else {
        _lugarSeleccionado = kOpcionOtro;
        lugarCtrl.text = lugar;
      }

      fechaCtrl.text = cita['FECHA'] ?? '';
      horaCtrl.text = cita['HORA'] ?? '';
      anotacionesCtrl.text = cita['ANOTACIONES'] ?? '';
      _idPersonaSeleccionada = cita['IDPERSONA'];

      final String fechaString = cita['FECHA'] ?? '';
      if (fechaString.isNotEmpty) {
        try {
          final parts = fechaString.split('/');
          if (parts.length == 3) {
            _initialDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (e) {
          debugPrint("Error al parsear fecha: $e");
          _initialDate = DateTime.now();
        }
      }
    }
  }

  Future<void> _cargarPersonas() async {
    final personas = await DB.mostrarPersonas();
    setState(() {
      _personas =
          personas.map((p) => {"idpersona": p.idpersona, "nombre": p.nombre}).toList();
    });
  }

  void _actualizarCallesDisponibles(String? colonia) {
    setState(() {
      _calleSeleccionada = null;
      _entreCalleSeleccionada = null;
      _callesDisponibles = [kOpcionOtro];
      _entreCallesDisponibles = [kOpcionOtro];

      if (colonia != null && colonia != kOpcionOtro) {
        final calles = kCallesPorColonia[colonia.toLowerCase()];
        if (calles != null) {
          _callesDisponibles.addAll(calles);
          _entreCallesDisponibles.addAll(calles);
        }
      }
    });
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final String formattedDate =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";

      setState(() {
        fechaCtrl.text = formattedDate;
        _initialDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        horaCtrl.text = pickedTime.format(context);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final esOtroLugar = _lugarSeleccionado == kOpcionOtro;

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? "Modificar Cita" : "Insertar Cita"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                  value: _lugarSeleccionado,
                  decoration: _buildInputDecoration("Lugar"),
                  isExpanded: true,
                  items: [
                    ...kLugaresFijosMap.keys
                        .map((lugar) => DropdownMenuItem(
                        value: lugar,
                        child: Text(
                          lugar,
                          overflow: TextOverflow.ellipsis,
                        )
                    ))
                        .toList(),
                    const DropdownMenuItem(value: kOpcionOtro, child: Text(kOpcionOtro)),
                  ],
                  onChanged: (valor) {
                    setState(() => _lugarSeleccionado = valor);
                  },
                  validator: (value) {
                    if (value == null) return 'Seleccione un lugar';
                    return null;
                  }
              ),

              if (esOtroLugar)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      TextFormField(
                          controller: lugarCtrl,
                          decoration: _buildInputDecoration("Nombre del lugar (ej. 'Casa de Juan')"),
                          validator: (value) {
                            if (esOtroLugar && (value == null || value.isEmpty)) {
                              return 'Ingrese el nombre del lugar';
                            }
                            return null;
                          }),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _coloniaSeleccionada,
                        hint: const Text("Seleccione Colonia"),
                        decoration: _buildInputDecoration("Colonia"),
                        isExpanded: true,
                        items: [
                          ...kColoniasTepic.map((col) => DropdownMenuItem(value: col, child: Text(col))),
                          const DropdownMenuItem(value: kOpcionOtro, child: Text(kOpcionOtro)),
                        ],
                        onChanged: (valor) {
                          setState(() {
                            _coloniaSeleccionada = valor;
                            _actualizarCallesDisponibles(valor);
                          });
                        },
                        validator: (value) {
                          if (esOtroLugar && value == null) return 'Seleccione una colonia';
                          return null;
                        },
                      ),
                      if (_coloniaSeleccionada == kOpcionOtro)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextFormField(
                            controller: coloniaOtroCtrl,
                            decoration: _buildInputDecoration("Escriba la Colonia"),
                            validator: (value) {
                              if (_coloniaSeleccionada == kOpcionOtro && (value == null || value.isEmpty)) {
                                return 'Escriba la colonia';
                              }
                              return null;
                            },
                          ),
                        ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _calleSeleccionada,
                        hint: const Text("Seleccione Calle"),
                        decoration: _buildInputDecoration("Calle Principal"),
                        isExpanded: true,
                        items: _callesDisponibles
                            .map((calle) => DropdownMenuItem(value: calle, child: Text(calle, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (valor) {
                          setState(() {
                            _calleSeleccionada = valor;
                          });
                        },
                        validator: (value) {
                          if (esOtroLugar && value == null) return 'Seleccione una calle';
                          return null;
                        },
                      ),
                      if (_calleSeleccionada == kOpcionOtro)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextFormField(
                            controller: calleOtroCtrl,
                            decoration: _buildInputDecoration("Escriba la Calle Principal"),
                            validator: (value) {
                              if (_calleSeleccionada == kOpcionOtro && (value == null || value.isEmpty)) {
                                return 'Escriba la calle principal';
                              }
                              return null;
                            },
                          ),
                        ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _entreCalleSeleccionada,
                        hint: const Text("Seleccione Entre Calle"),
                        decoration: _buildInputDecoration("Entre Calle (Opcional)"),
                        isExpanded: true,
                        items: _entreCallesDisponibles
                            .map((calle) => DropdownMenuItem(value: calle, child: Text(calle, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (valor) {
                          setState(() {
                            _entreCalleSeleccionada = valor;
                          });
                        },
                      ),
                      if (_entreCalleSeleccionada == kOpcionOtro)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextFormField(
                            controller: entreCalleOtroCtrl,
                            decoration: _buildInputDecoration("Escriba la Entre Calle"),
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              TextFormField(
                  controller: fechaCtrl,
                  decoration: _buildInputDecoration("Fecha"),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese una fecha';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              TextFormField(
                  controller: horaCtrl,
                  decoration: _buildInputDecoration("Hora"),
                  readOnly: true,
                  onTap: () => _selectTime(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese una hora';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              TextFormField(
                  controller: anotacionesCtrl,
                  decoration: _buildInputDecoration("Anotaciones (Opcional)")),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _idPersonaSeleccionada,
                items: _personas.map((p) {
                  return DropdownMenuItem<int>(
                    value: p["idpersona"],
                    child: Text(p["nombre"]),
                  );
                }).toList(),
                decoration: _buildInputDecoration("Persona"),
                onChanged: (valor) => setState(() => _idPersonaSeleccionada = valor),
                validator: (value) {
                  if (value == null) {
                    return 'Seleccione una persona';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: _mainButtonStyle,
                onPressed: _isSaving ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() { _isSaving = true; });

                    String lugarFinal;
                    double latitud = _defaultCoords.latitude;
                    double longitud = _defaultCoords.longitude;

                    try {
                      if (esOtroLugar) {
                        lugarFinal = lugarCtrl.text;

                        String coloniaFinal = _coloniaSeleccionada == kOpcionOtro
                            ? coloniaOtroCtrl.text
                            : _coloniaSeleccionada ?? '';
                        String calleFinal = _calleSeleccionada == kOpcionOtro
                            ? calleOtroCtrl.text
                            : _calleSeleccionada ?? '';

                        if (calleFinal.isNotEmpty && coloniaFinal.isNotEmpty) {
                          String direccion = "$calleFinal, $coloniaFinal, Tepic, Nayarit, Mexico";
                          debugPrint("Geocodificando: $direccion");

                          List<Location> locations = await locationFromAddress(direccion);

                          if (locations.isEmpty) {
                            throw Exception("Dirección no encontrada. Verifique Calle y Colonia.");
                          }

                          latitud = locations.first.latitude;
                          longitud = locations.first.longitude;
                          debugPrint("Coordenadas encontradas: $latitud, $longitud");

                        } else if (!_esEdicion) {
                          throw Exception("Debe especificar Colonia y Calle para un lugar 'Otro'.");
                        } else {
                          // Si es edición y no se provee nueva dirección, reusar las coords existentes
                          latitud = widget.citaAEditar!['LATITUD'] ?? _defaultCoords.latitude;
                          longitud = widget.citaAEditar!['LONGITUD'] ?? _defaultCoords.longitude;
                          debugPrint("Reusando coordenadas existentes para 'Otro': $latitud, $longitud");
                        }

                      } else {
                        lugarFinal = _lugarSeleccionado!;
                        final coords = kLugaresFijosMap[lugarFinal]!;
                        latitud = coords.latitude;
                        longitud = coords.longitude;
                      }

                      if (_esEdicion) {
                        final c = Cita(
                          idcita: widget.citaAEditar!['IDCITA'],
                          lugar: lugarFinal, fecha: fechaCtrl.text, hora: horaCtrl.text,
                          anotaciones: anotacionesCtrl.text, idpersona: _idPersonaSeleccionada!,
                          latitud: latitud, longitud: longitud,
                        );
                        await DB.actualizarCita(c);
                        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cita actualizada")));
                      } else {
                        final c = Cita(
                          lugar: lugarFinal, fecha: fechaCtrl.text, hora: horaCtrl.text,
                          anotaciones: anotacionesCtrl.text, idpersona: _idPersonaSeleccionada!,
                          latitud: latitud, longitud: longitud,
                        );
                        await DB.insertarCita(c);
                        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cita insertada")));
                      }

                      if (mounted) Navigator.pop(context);

                    } catch (e) {
                      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al obtener coordenadas o guardar: ${e.toString().replaceFirst("Exception: ", "")}")),
                      );
                    } finally {
                      if (mounted) setState(() { _isSaving = false; });
                    }

                  } else {
                    if(mounted) ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Por favor, complete todos los campos requeridos")),
                    );
                  }
                },
                child: _isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : Text(_esEdicion ? "Actualizar" : "Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MostrarCitasPage extends StatefulWidget {
  const MostrarCitasPage({super.key});

  @override
  State<MostrarCitasPage> createState() => _MostrarCitasPageState();
}

class _MostrarCitasPageState extends State<MostrarCitasPage> {
  // Usamos listas de estado y un Future<void> para la carga
  Future<void>? _loadFuture;
  List<Map<String, dynamic>> _citasHoy = [];
  List<Map<String, dynamic>> _citasProximas = [];
  List<Map<String, dynamic>> _citasPasadas = [];
  List<Map<String, dynamic>> _citasSinFecha = [];

  // --- MÉTODOS DE PARSEO ---

  TimeOfDay? _parseHora(String? horaString) {
    if (horaString == null || horaString.isEmpty) return null;

    try {
      final parts = horaString.split(' ');
      if (parts.length != 2) return null;

      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;

      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      final String ampm = parts[1].toUpperCase();

      if (ampm == 'PM' && hour != 12) {
        hour += 12;
      } else if (ampm == 'AM' && hour == 12) {
        hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      debugPrint("Error al parsear hora '$horaString': $e");
      return null;
    }
  }

  DateTime? _parseFecha(String? fechaString) {
    if (fechaString == null || fechaString.isEmpty) return null;

    try {
      final parts = fechaString.split('/');
      if (parts.length != 3) return null;

      final int day = int.parse(parts[0]);
      final int month = int.parse(parts[1]);
      final int year = int.parse(parts[2]);

      if (day > 31 || month > 12 || year < 1900) return null;

      return DateTime(year, month, day);
    } catch (e) {
      debugPrint("Error al parsear fecha '$fechaString': $e");
      return null;
    }
  }

  DateTime _getCombinedDateTime(Map<String, dynamic> cita, DateTime fallback) {
    final DateTime? fecha = _parseFecha(cita['FECHA']);
    final TimeOfDay? hora = _parseHora(cita['HORA']);

    if (fecha != null) {
      if (hora != null) {
        return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
      }
      return fecha;
    }
    return fallback;
  }

  // --- LÓGICA DE DATOS ---

  Future<void> _fetchAndSortCitas() async {
    final citas = await DB.mostrarCitasConPersona();
    final now = DateTime.now();
    // Usamos una fecha "limpia" (medianoche) para comparar solo el día
    final todayDate = DateTime(now.year, now.month, now.day);

    final farFuture = DateTime(9999);
    final farPast = DateTime(1900);

    // Listas temporales para clasificación
    final List<Map<String, dynamic>> todayEvents = [];
    final List<Map<String, dynamic>> pastEvents = [];
    final List<Map<String, dynamic>> futureEvents = [];
    final List<Map<String, dynamic>> unknownDateEvents = [];

    for (final cita in citas) {
      final DateTime? fecha = _parseFecha(cita['FECHA']);
      if (fecha == null) {
        unknownDateEvents.add(cita);
        continue;
      }

      // 1. Comparamos si la FECHA es la de hoy
      bool esHoy = fecha.year == todayDate.year &&
          fecha.month == todayDate.month &&
          fecha.day == todayDate.day;

      if (esHoy) {
        todayEvents.add(cita);
        continue; // La cita es de hoy, no la procesamos como futura o pasada
      }

      // 2. Si no es de hoy, verificamos si es futura o pasada
      final TimeOfDay? hora = _parseHora(cita['HORA']);
      final DateTime dt = hora != null
          ? DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute)
          : DateTime(fecha.year, fecha.month, fecha.day, 23, 59); // Hora de 'fallback' para citas sin hora

      if (dt.isBefore(now)) {
        pastEvents.add(cita);
      } else {
        futureEvents.add(cita);
      }
    }

    // --- Ordenamos las listas ---
    todayEvents.sort((a, b) {
      final DateTime dtA = _getCombinedDateTime(a, farFuture);
      final DateTime dtB = _getCombinedDateTime(b, farFuture);
      return dtA.compareTo(dtB);
    });

    futureEvents.sort((a, b) {
      final DateTime dtA = _getCombinedDateTime(a, farFuture);
      final DateTime dtB = _getCombinedDateTime(b, farFuture);
      return dtA.compareTo(dtB);
    });

    pastEvents.sort((a, b) {
      final DateTime dtA = _getCombinedDateTime(a, farPast);
      final DateTime dtB = _getCombinedDateTime(b, farPast);
      return dtB.compareTo(dtA);
    });

    // Actualizamos el estado con las listas clasificadas
    if (mounted) {
      setState(() {
        _citasHoy = todayEvents;
        _citasProximas = futureEvents;
        _citasPasadas = pastEvents;
        _citasSinFecha = unknownDateEvents;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Asignamos el Future a nuestra variable de estado
    _loadFuture = _fetchAndSortCitas();
  }

  void _recargarCitas() {
    setState(() {
      // Limpiamos listas para que muestre el 'loading'
      _citasHoy = [];
      _citasProximas = [];
      _citasPasadas = [];
      _citasSinFecha = [];
      // Volvemos a ejecutar el Future de carga
      _loadFuture = _fetchAndSortCitas();
    });
  }

  // --- WIDGETS DE CONSTRUCCIÓN (MODIFICADOS PARA "GRITAR") ---

  Widget _buildCitaTile(Map<String, dynamic> c, {bool esDestacada = false}) {
    if (esDestacada) {
      // --- ESTILO "IDIOTA, MIRA AQUÍ" ---
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: Colors.teal.shade50, // Un fondo más notable
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _primaryColor, width: 2), // Borde más grueso
        ),
        elevation: 4, // Más sombra
        child: ListTile(
          leading: CircleAvatar( // <-- CAMBIO: Círculo llamativo
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.today_rounded, size: 28), // Icono grande dentro
          ),
          title: Text(
              "${c['LUGAR']}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17, // Ligeramente más grande
                  color: Colors.black87
              )
          ),
          subtitle: Text(
            "${c['NOMBRE_PERSONA']} - ${c['HORA'] ?? ''} (${c['FECHA'] ?? ''})",
            style: const TextStyle(
                fontWeight: FontWeight.w500, // Subtítulo más grueso
                color: Colors.black54
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.map_outlined, color: Colors.blueAccent),
                tooltip: "Ver en mapa",
                onPressed: () {
                  Navigator.pop(context, c);
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: _primaryColor),
                tooltip: "Editar cita",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InsertarCitaPage(citaAEditar: c),
                    ),
                  ).then((_) => _recargarCitas());
                },
              ),
            ],
          ),
        ),
      );
    }

    // --- ESTILO NORMAL ---
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.event_note, color: _primaryColor),
        title: Text("${c['LUGAR']}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${c['NOMBRE_PERSONA']} - ${c['HORA'] ?? ''} (${c['FECHA'] ?? ''})"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.map_outlined, color: Colors.blueAccent),
              tooltip: "Ver en mapa",
              onPressed: () {
                Navigator.pop(context, c);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: _primaryColor),
              tooltip: "Editar cita",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InsertarCitaPage(citaAEditar: c),
                  ),
                ).then((_) => _recargarCitas());
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir los títulos de cada sección
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos FutureBuilder<void> que observa nuestro Future de carga
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {

        // Comprobamos si, una vez cargado, todas las listas están vacías
        final bool isEmpty = _citasHoy.isEmpty &&
            _citasProximas.isEmpty &&
            _citasPasadas.isEmpty &&
            _citasSinFecha.isEmpty;

        // Caso 1: Aún cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Citas"),
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Caso 2: Carga terminada, pero no hay datos
        if (isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Citas"),
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: Text("No hay citas registradas.")),
          );
        }

        // Caso 3: Carga terminada y hay datos
        return Scaffold(
          appBar: AppBar(
            title: const Text("Citas"),
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
          ),
          // Usamos un ListView simple que contendrá nuestras secciones
          body: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // --- SECCIÓN "HOY" ---
              if (_citasHoy.isNotEmpty)
                _buildSectionHeader("Citas del Día de Hoy"),
              // Pasamos 'esDestacada: true'
              ..._citasHoy.map((c) => _buildCitaTile(c, esDestacada: true)),

              // --- SECCIÓN "PRÓXIMAS" ---
              if (_citasProximas.isNotEmpty)
                _buildSectionHeader("Próximas Citas"),
              ..._citasProximas.map((c) => _buildCitaTile(c)),

              // --- SECCIÓN "PASADAS" ---
              if (_citasPasadas.isNotEmpty)
                _buildSectionHeader("Citas Pasadas"),
              ..._citasPasadas.map((c) => _buildCitaTile(c)),

              // --- SECCIÓN "SIN FECHA" ---
              if (_citasSinFecha.isNotEmpty)
                _buildSectionHeader("Citas sin Fecha"),
              ..._citasSinFecha.map((c) => _buildCitaTile(c)),
            ],
          ),
        );
      },
    );
  }
}

class EliminarCitaPage extends StatefulWidget {
  const EliminarCitaPage({super.key});

  @override
  State<EliminarCitaPage> createState() => _EliminarCitaPageState();
}

class _EliminarCitaPageState extends State<EliminarCitaPage> {
  List<Map<String, dynamic>> _citas = [];
  int? _selectedCitaId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    setState(() { _isLoading = true; });
    final citas = await DB.mostrarCitasConPersona();
    if (mounted) {
      setState(() {
        _citas = citas;
        _isLoading = false;
      });
    }
  }

  Future<bool> _mostrarDialogoConfirmacion() async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Está seguro de que desea eliminar esta cita?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
    return confirmado ?? false;
  }

  void _eliminarCita() async {
    if (_selectedCitaId == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, seleccione una cita.")),
      );
      return;
    }

    final bool confirmado = await _mostrarDialogoConfirmacion();

    if (confirmado) {
      await DB.eliminarCita(_selectedCitaId!);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cita eliminada")),
      );
      setState(() {
        _selectedCitaId = null;
      });
      _cargarCitas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eliminar Cita"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              DropdownButtonFormField<int>(
                value: _selectedCitaId,
                hint: const Text("Seleccione una cita"),
                decoration: _buildInputDecoration("Cita a eliminar"),
                isExpanded: true,
                items: _citas.map((c) {
                  return DropdownMenuItem<int>(
                    value: c['IDCITA'],
                    child: Text(
                      "${c['LUGAR']} - ${c['NOMBRE_PERSONA']} (${c['FECHA'] ?? ''})",
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _selectedCitaId = valor;
                  });
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _eliminarCita,
              style: _deleteButtonStyle,
              child: const Text("Eliminar"),
            )
          ],
        ),
      ),
    );
  }
}