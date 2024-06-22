import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:komunly/repository/social.repository.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/widgets/snackbars.dart';

class CreateEvents extends StatefulWidget {
  const CreateEvents({super.key});

  @override
  State<CreateEvents> createState() => _CreateEventsState();
}

class _CreateEventsState extends State<CreateEvents> {
  late TextEditingController _titleController;
  late DateTime _selectedDate = DateTime.now();
  String _eventType = 'free';
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  String _formatMonth(int month) {
    return month.toString().padLeft(2, '0');
  }
  Future<void> _createEvent() async {
    final String title = _titleController.text;
    // Formateamos la fecha para asegurarnos de que el mes tenga dos dígitos
    final String setDate =
        "${_selectedDate.year}-${_formatMonth(_selectedDate.month)}-${_selectedDate.day}";

    final String type = _eventType;

    try {
      var response = await createEvent(context, {"title": title, "setDate": setDate, "type": type});

      if (response.statusCode == 201) {
        showSnackMessage(context, "Evento creado con éxito", "SUCCESS");
        setState(() {});
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: "Crear Evento"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del evento',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fecha del evento',
              style: TextStyle(color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    '${_selectedDate.year}-${_formatMonth(_selectedDate.month)}-${_selectedDate.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                )
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Tipo de Evento',
              style: TextStyle(color: Colors.white),
            ),
            DropdownButton<String>(
              dropdownColor: Colors.black,
              menuMaxHeight: double.infinity,
              value: _eventType,
              onChanged: (String? newValue) {
                setState(() {
                  _eventType = newValue!;
                });
              },
              items: <String>['free', 'premium']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value == 'free' ? 'Gratis' : 'Premium',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _createEvent();
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 225, 255, 0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'Crear Evento',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
