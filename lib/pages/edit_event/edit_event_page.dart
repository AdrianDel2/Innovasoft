import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/event_model.dart';
import '../../repositories/event_repository.dart';
import '../widgets/action_button.dart';
import '../home/admin_event_home_page.dart';
import 'edit_event_success_page.dart';
import 'edit_event_error_page.dart';

import 'dart:convert';

class EditEventPage extends StatefulWidget {
  const EditEventPage({super.key});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  DateTime? fechaHoraInicio;
  DateTime? fechaHoraFin;

  String? selectedEvent;
  String? selectedMunicipio;
  final EventRepository _repo = EventRepository();
  List<EventModel> _eventos = [];
  List<String> municipios = [];

  @override
  void initState() {
    super.initState();
    _cargarEventos();
    _cargarMunicipios();
  }

  Future<void> _cargarEventos() async {
    try {
      final eventos = await _repo.obtenerEventosRemotos();
      setState(() {
        _eventos = eventos.where((e) => e.estado == 'activo').toList();
        print("Eventos cargados: ${_eventos.map((e) => e.nombre).toList()}");

      });
    } catch (e) {
      // Mostrar error al usuario (puede ser SnackBar, AlertDialog, etc.)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar eventos !')),
        );
      }
    }
  }

  Future<void> _cargarMunicipios() async {
    final String response = await rootBundle.loadString('assets/utils/municipios_cauca.json');
    final List<dynamic> data = List.from(jsonDecode(response));
    setState(() {
      municipios = data.map((e) => e.toString()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/logo_indeportes.png', width: 200),
                const SizedBox(height: 10),
                const Text('“Indeportes somos todos”', style: TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                const Text('Editar Evento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildDropdownField(),
                const SizedBox(height: 20),
                _buildField(label: 'Nombre', controller: nameController),
                _buildMunicipioDropdown(),
                _buildField(label: 'Descripción', controller: descripcionController),
                _buildDateTimePicker(context, 'Fecha y hora de inicio', true),
                _buildDateTimePicker(context, 'Fecha y hora de fin', false),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      text: 'Actualizar',
                      color: Color(0xFF038C65),
                      ancho: 145,
                      alto: 50,
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            selectedEvent != null &&
                            selectedMunicipio != null) {
                          final idEvento = int.parse(selectedEvent!);
                          final eventoActualizado = EventModel(
                            id_evento: idEvento,
                            nombre: nameController.text.trim(),
                            descripcion: descripcionController.text.trim(),
                            fecha_hora_inicio: fechaHoraInicio!,
                            fecha_hora_fin: fechaHoraFin!,
                            ubicacion: selectedMunicipio!,
                            estado: 'activo',
                          );

                          //final result = await _repo.actualizarEvento(eventoActualizado);
                          final result = await _repo.actualizarEventoParcialRemoto(idEvento,eventoActualizado);

                          if (result) {
                            // Ir a página de éxito
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditEventSuccessPage()),
                            );
                          } else {
                            // Ir a página de error
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditEventErrorPage()),
                            );
                          }
                        } else {
                          // Campos incompletos: aún puedes usar un SnackBar aquí si deseas
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor completa todos los campos')),
                          );
                        }
                      },
                    ),
                    ActionButton(
                      text: 'Regresar',
                      color: Color.fromARGB(255, 134, 134, 134),
                      icono: Icons.arrow_back,
                      ancho: 160,
                      alto: 50,
                      //onPressed: () => Navigator.pop(context),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => AdminEventHomePage()),
                          (Route<dynamic> route) => false, // elimina todas las rutas anteriores
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar evento',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: _eventos.map((evento) {
        return DropdownMenuItem<String>(
          value: evento.id_evento.toString(),
          child: Text(evento.nombre),
        );
      }).toList(),
      value: selectedEvent,
      onChanged: (value) {
        setState(() {
          selectedEvent = value;
          final evento = _eventos.firstWhere((e) => e.id_evento.toString() == value);
          nameController.text = evento.nombre;
          descripcionController.text = evento.descripcion ?? '';
          locationController.text = evento.ubicacion;
          selectedMunicipio = evento.ubicacion;
          fechaHoraInicio = evento.fecha_hora_inicio;
          fechaHoraFin = evento.fecha_hora_fin;
        });
      },
    );
  }

  Widget _buildMunicipioDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Selecciona un municipio',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            value: selectedMunicipio,
            items: municipios.map((municipio) {
              return DropdownMenuItem<String>(
                value: municipio,
                child: Text(municipio),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMunicipio = value;
                locationController.text = value!;
              });
            },
            validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
            decoration: InputDecoration(
              hintText: 'Ingrese $label',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, String label, bool isInicio) {
    final selectedDateTime = isInicio ? fechaHoraInicio : fechaHoraFin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _selectDateTime(context, isInicio),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: label,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              child: Text(
                selectedDateTime != null
                    ? DateFormat('dd-MM-yyyy HH:mm').format(selectedDateTime)
                    : 'Selecciona fecha y hora',
                style: TextStyle(
                  color: selectedDateTime != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context, bool isInicio) async {
    final DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (time != null) {
        final DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

        if (isInicio) {
          if (dateTime.isBefore(now)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La fecha de inicio no puede ser anterior a la fecha actual')),
            );
            return;
          }
          setState(() {
            fechaHoraInicio = dateTime;
          });
        } else {
          if (fechaHoraInicio == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Primero selecciona la fecha de inicio')),
            );
            return;
          }
          if (dateTime.isBefore(fechaHoraInicio!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La fecha de fin no puede ser anterior a la fecha de inicio')),
            );
            return;
          }
          setState(() {
            fechaHoraFin = dateTime;
          });
        }
      }
    }
  }
}