import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '/providers/auth_provider.dart';
import '../models/calendario_model.dart';
import '../providers/calendario_provider.dart';

const List<String> rolesImprenta = [
  'Admin',
  'Offset',
  'Diseño',
  'Corte',
  'Suaje',
  'Laminado',
  'Acabado',
  'Logistica',
  'Serigrafia',
  'Grabado',
  'Barniz',
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
  final Set<String> _areasFiltro = {};

  bool _isDayInRange(DateTime day, DateTime start, DateTime end) {
    final diaSeleccionado = DateTime(day.year, day.month, day.day);
    final inicio = DateTime(start.year, start.month, start.day);
    final fin = DateTime(end.year, end.month, end.day);
    return diaSeleccionado.compareTo(inicio) >= 0 &&
        diaSeleccionado.compareTo(fin) <= 0;
  }

  List<Calendario> _getActividadesPorDia(
    DateTime day,
    List<Calendario> todasLasActividades,
    String rolUsuario,
  ) {
    return todasLasActividades.where((act) {
      final enRango = _isDayInRange(day, act.fechaInicio, act.fechaFin);
      if (rolUsuario == 'Admin') {
        if (_areasFiltro.isEmpty) return enRango;
        return enRango && _areasFiltro.contains(act.area);
      }
      return enRango && act.area.toLowerCase() == rolUsuario.toLowerCase();
    }).toList();
  }

  void _eliminarActividad(String id) async {
    final success = await ref
        .read(calendarioProvider.notifier)
        .eliminarCalendario(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Actividad eliminada del flujo de producción.'),
        ),
      );
    }
  }

  void _abrirFormularioNuevaActividad(
    ColorScheme colors,
    String? currentUserId,
  ) {
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
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asignar Actividad a Producción',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final pickedRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                    initialDateRange: DateTimeRange(
                      start: inicioRango,
                      end: finRango,
                    ),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(colorScheme: colors),
                      child: child!,
                    ),
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
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline),
                    borderRadius: BorderRadius.circular(8),
                    color: colors.surfaceContainerHighest.withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.date_range_rounded, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Período',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Del ${inicioRango.day}/${inicioRango.month} al ${finRango.day}/${finRango.month}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'No. de Orden y proyecto',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => titulo = val,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Instrucciones',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => descripcion = val,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: areaAsignada,
                decoration: const InputDecoration(
                  labelText: 'Área',
                  border: OutlineInputBorder(),
                ),
                items: rolesImprenta
                    .where((rol) => rol != 'Admin')
                    .map(
                      (rol) => DropdownMenuItem(value: rol, child: Text(rol)),
                    )
                    .toList(),
                onChanged: (val) => setModalState(() => areaAsignada = val!),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Asignar Orden Multi-día'),
                onPressed: () async {
                  if (titulo.isNotEmpty) {
                    final nuevaActividad = Calendario(
                      titulo: titulo,
                      descripcion: descripcion,
                      fechaInicio: inicioRango,
                      fechaFin: finRango,
                      usuarioId: currentUserId,
                      area: areaAsignada,
                    );

                    final success = await ref
                        .read(calendarioProvider.notifier)
                        .crearCalendario(nuevaActividad);
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Actividad asignada a producción.'),
                        ),
                      );
                    }
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
    final String? idUsuario = authState.usuario?.id;
    final bool esAdmin = (rolUsuario == 'Admin');

    final estadoActividades = ref.watch(calendarioProvider);
    final listaActividadesDia = _getActividadesPorDia(
      _selectedDay ?? _focusedDay,
      estadoActividades.calendarios,
      rolUsuario,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Producción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar calendario',
            onPressed: () {
              ref.invalidate(calendarioProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Actualizando calendario...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: esAdmin
          ? FloatingActionButton.extended(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Asignar Orden'),
              onPressed: () =>
                  _abrirFormularioNuevaActividad(colors, idUsuario),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (esAdmin) _buildFiltroAreas(colors),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              child: _buildCalendarioCard(
                                colors,
                                estadoActividades,
                                rolUsuario,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 6,
                            child: _buildListaActividades(
                              listaActividadesDia,
                              colors,
                              esAdmin,
                              estadoActividades.isLoading,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildCalendarioCard(
                            colors,
                            estadoActividades,
                            rolUsuario,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _buildListaActividades(
                              listaActividadesDia,
                              colors,
                              esAdmin,
                              estadoActividades.isLoading,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroAreas(ColorScheme colors) {
    final areas = rolesImprenta.where((r) => r != 'Admin').toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt_rounded, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Filtrar por área / usuario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const Spacer(),
                if (_areasFiltro.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _areasFiltro.clear()),
                    child: const Text('Ver todas'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: areas.map((area) {
                final selected = _areasFiltro.contains(area);
                return FilterChip(
                  label: Text(area),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _areasFiltro.add(area);
                      } else {
                        _areasFiltro.remove(area);
                      }
                    });
                  },
                  selectedColor: colors.primaryContainer,
                  checkmarkColor: colors.onPrimaryContainer,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarioCard(
    ColorScheme colors,
    CalendarioState state,
    String rolUsuario,
  ) {
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
          eventLoader: (day) =>
              _getActividadesPorDia(day, state.calendarios, rolUsuario),
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
            todayDecoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: colors.error,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
          ),
        ),
      ),
    );
  }

  Widget _buildListaActividades(
    List<Calendario> listaActividadesDia,
    ColorScheme colors,
    bool esAdmin,
    bool isLoading,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (listaActividadesDia.isEmpty) {
      return Center(
        child: Text(
          'Sin órdenes programadas.',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      itemCount: listaActividadesDia.length,
      itemBuilder: (context, index) {
        final actividad = listaActividadesDia[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(
              actividad.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Del ${actividad.fechaInicio.day}/${actividad.fechaInicio.month} al ${actividad.fechaFin.day}/${actividad.fechaFin.month} - Área: ${actividad.area}',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    actividad.descripcion,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            trailing: esAdmin
                ? IconButton(
                    icon: Icon(Icons.delete, color: colors.error),
                    onPressed: () => _eliminarActividad(actividad.id!),
                  )
                : null,
          ),
        );
      },
    );
  }
}