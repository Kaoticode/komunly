import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/events";
    final String title = _titleController.text;

    // Formateamos la fecha para asegurarnos de que el mes tenga dos dígitos
    final String setDate =
        "${_selectedDate.year}-${_formatMonth(_selectedDate.month)}-${_selectedDate.day}";

    final String type = _eventType;

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({"title": title, "setDate": setDate, "type": type}),
      );

      if (response.statusCode == 201) {
        showSnackMessage(context, "Evento creado con éxito", "SUCCESS");
        setState(() {});
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        refreshTokens();
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

  Future<void> refreshTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    String? refreshToken = prefs.getString('refresh_token');
    String apiUrl = "$API_URL/auth/refreshTokens";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        String accessToken = jsonResponse['access_token'];
        await prefs.setString('access_token', accessToken);
        showSnackMessage(context,
            "Tokens Refrescados, vuelve a ejecutar la función", "SUCCESS");
      } else if (response.statusCode != 201) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('user_id');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
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
