import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '/providers/auth_provider.dart';

// 1. MODELO DE DATOS ACTUALIZADO PARA RANGOS DE FECHAS
class Actividad {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String asignadoA;

  Actividad({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.asignadoA,
  });

  //  Agrega aquí un factory constructor 'fromJson' 
  // para convertir el objeto Map que recibas de NeonDB a un objeto Actividad.
}

const List<String> rolesImprenta = [
  'Admin', 'Offset', 'Diseño', 'Corte', 'Suaje', 
  'Laminado', 'Acabado', 'Logistica', 'Serigrafia', 
  'Grabado', 'Barniz'
];

class CalendarioScreen extends ConsumerStatefulWidget {
  const CalendarioScreen({super.key});

  @override
  ConsumerState<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends ConsumerState<CalendarioScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  //  Esta lista es temporal. Aquí deberás usar un Provider
  final List<Actividad> _actividadesMock = [
    Actividad(
      id: '1',
      titulo: 'Orden #5021 - Tarjetas Acabado Mate',
      descripcion: 'Laminado bopp mate por ambas caras, revisión de burbujas.',
      fechaInicio: DateTime.now(),
      fechaFin: DateTime.now().add(const Duration(days: 2)),
      asignadoA: 'Laminado',
    ),
    Actividad(
      id: '2',
      titulo: 'Orden #5022 - Volantes Volaris',
      descripcion: 'Tiraje de 10,000 pzas. Cuidar el registro de los textos.',
      fechaInicio: DateTime.now().subtract(const Duration(days: 1)),
      fechaFin: DateTime.now().add(const Duration(days: 1)),
      asignadoA: 'Offset',
    ),
  ];

  bool _isDayInRange(DateTime day, DateTime start, DateTime end) {
    final diaSeleccionado = DateTime(day.year, day.month, day.day);
    final inicio = DateTime(start.year, start.month, start.day);
    final fin = DateTime(end.year, end.month, end.day);
    
    return diaSeleccionado.compareTo(inicio) >= 0 && diaSeleccionado.compareTo(fin) <= 0;
  }

  List<Actividad> _getActividadesPorDia(DateTime day, String rolUsuario) {
    // 💡 GUÍA PARA DB: Al migrar a DB, realiza la consulta SQL filtrando 
    // por fechas e ID de usuario/rol desde el servidor (PostgreSQL) en lugar de filtrar en memoria.
    return _actividadesMock.where((act) {
      final enRango = _isDayInRange(day, act.fechaInicio, act.fechaFin);
      if (rolUsuario == 'Admin') return enRango; 
      return enRango && act.asignadoA.toLowerCase() == rolUsuario.toLowerCase(); 
    }).toList();
  }

  void _eliminarActividad(String id) {
    //  Aquí debes ejecutar: await supabase.from('actividades').delete().eq('id', id);
    // Y luego llamar a ref.invalidate(tuProviderDeActividades) para refrescar la UI.
    setState(() {
      _actividadesMock.removeWhere((element) => element.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Actividad eliminada del flujo de producción.')),
    );
  }

  void _abrirFormularioNuevaActividad(ColorScheme colors) {
    String titulo = '';
    String descripcion = '';
    String areaAsignada = 'Offset'; 
    DateTime inicioRango = _selectedDay ?? DateTime.now();
    DateTime finRango = _selectedDay ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600), 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24, left: 24, right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Asignar Actividad a Producción', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () async {
                  final pickedRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                    initialDateRange: DateTimeRange(start: inicioRango, end: finRango),
                    builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: colors), child: child!),
                  );

                  if (pickedRange != null) {
                    setModalState(() {
                      inicioRango = pickedRange.start;
                      finRango = pickedRange.end;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: colors.outline), borderRadius: BorderRadius.circular(8), color: colors.surfaceContainerHighest.withOpacity(0.3)),
                  child: Row(
                    children: [
                      Icon(Icons.date_range_rounded, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Período', style: TextStyle(fontSize: 12)), Text('Del ${inicioRango.day}/${inicioRango.month} al ${finRango.day}/${finRango.month}', style: const TextStyle(fontWeight: FontWeight.bold))])),
                      const Icon(Icons.edit, size: 18),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              TextField(decoration: const InputDecoration(labelText: 'Título o No. de Orden', border: OutlineInputBorder()), onChanged: (val) => titulo = val),
              const SizedBox(height: 16),
              TextField(decoration: const InputDecoration(labelText: 'Instrucciones', border: OutlineInputBorder()), onChanged: (val) => descripcion = val),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: areaAsignada,
                decoration: const InputDecoration(labelText: 'Área', border: OutlineInputBorder()),
                items: rolesImprenta.where((rol) => rol != 'Admin').map((rol) => DropdownMenuItem(value: rol, child: Text(rol))).toList(),
                onChanged: (val) => setModalState(() => areaAsignada = val!),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Asignar Orden Multi-día'),
                onPressed: () {
                  if (titulo.isNotEmpty) {
                    //  Ejecuta aquí: await supabase.from('actividades').insert({...});
                    // Y luego: ref.invalidate(tuProvider);
                    setState(() {
                      _actividadesMock.add(Actividad(
                        id: DateTime.now().toString(),
                        titulo: titulo,
                        descripcion: descripcion,
                        fechaInicio: inicioRango,
                        fechaFin: finRango,
                        asignadoA: areaAsignada,
                      ));
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);
    final String rolUsuario = authState.usuario?.tipoUsuario ?? 'Diseño';
    final bool esAdmin = (rolUsuario == 'Admin');
    
    //  Si usas un FutureProvider/StreamProvider de Riverpod,
    // usa 'final listaActividades = ref.watch(providerDeActividades);' 
    // y maneja los estados con '.when(...)'.
    final listaActividadesDia = _getActividadesPorDia(_selectedDay ?? _focusedDay, rolUsuario);

    return Scaffold(
      floatingActionButton: esAdmin
          ? FloatingActionButton.extended(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Asignar Orden'),
              onPressed: () => _abrirFormularioNuevaActividad(colors),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: SingleChildScrollView(child: _buildCalendarioCard(colors, rolUsuario))),
                    const SizedBox(width: 24),
                    Expanded(flex: 6, child: _buildListaActividades(listaActividadesDia, colors, esAdmin)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildCalendarioCard(colors, rolUsuario),
                    const SizedBox(height: 16),
                    Expanded(child: _buildListaActividades(listaActividadesDia, colors, esAdmin)),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarioCard(ColorScheme colors, String rolUsuario) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) => _getActividadesPorDia(day, rolUsuario),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
            markerDecoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
          ),
          headerStyle: HeaderStyle(formatButtonVisible: true, titleCentered: true),
        ),
      ),
    );
  }

Widget _buildListaActividades(List<Actividad> listaActividadesDia, ColorScheme colors, bool esAdmin) {
    if (listaActividadesDia.isEmpty) {
      return Center(child: Text('Sin órdenes programadas.', style: TextStyle(color: colors.onSurfaceVariant)));
    }

    return ListView.builder(
      itemCount: listaActividadesDia.length,
      itemBuilder: (context, index) {
        final actividad = listaActividadesDia[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(actividad.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Del ${actividad.fechaInicio.day}/${actividad.fechaInicio.month} al ${actividad.fechaFin.day}/${actividad.fechaFin.month}',
                    style: TextStyle(color: colors.primary, fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    actividad.descripcion,
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                    maxLines: 3, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            trailing: esAdmin
                ? IconButton(icon: Icon(Icons.delete, color: colors.error), onPressed: () => _eliminarActividad(actividad.id))
                : null,
          ),
        );
      },
    );
  }
}