import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/create_events_page.dart';
import 'package:komunly/repository/api.repository.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  List<dynamic> eventsData = [];
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late int _thisYear;
  late int _thisMonth;
  late String myUserId;
  final Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];

  void fetchEventos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/events";

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        eventsData = jsonResponse['data'];

        setState(() {
          _loadEvents();
        });
         _onDaySelected(_selectedDay, _focusedDay);
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        refreshTokens(context);
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

  void deleteEvent(eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/events/$eventId";

    try {
      var response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        showSnackMessage(context, "Evento eliminado con éxito", "SUCCESS");
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        refreshTokens(context);
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _thisYear = DateTime.now().year;
    _thisMonth = DateTime.now().month;
    fetchEventos();
    getMyUserId();
  }

  Future<void> getMyUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUserId = prefs.getString('user_id')!;
  }

  void _loadEvents() {
    for (var event in eventsData) {
      DateTime setDate = DateTime.parse(event['setDate']).toLocal();
      DateTime formattedDate =
          DateTime(setDate.year, setDate.month, setDate.day);
      _events[formattedDate] ??= [];
      _events[formattedDate]!.add(event);
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    // Ignorar la hora, el minuto y el segundo al seleccionar el día
    day = DateTime(day.year, day.month, day.day);
    setState(() {
      _selectedDay = day;
    });

    // Llama a _showSelectedDayEvents para mostrar los eventos del día seleccionado
    _showSelectedDayEvents();
  }

  void _showSelectedDayEvents() {
    setState(() {
      // Actualizar los eventos para el día seleccionado
      _selectedEvents = _getEventsForDay(_selectedDay);
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Ignorar la hora, el minuto y el segundo al comparar los días
    DateTime compareDay = DateTime(day.year, day.month, day.day);
    return _events[compareDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 0, left: 8.0, right: 8.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateEvents()),
                  );
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
            ),
          ),
          TableCalendar(
            availableGestures: AvailableGestures.none,
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white, fontSize: 14),
            ),
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(_thisYear, _thisMonth, 1),
            lastDay: DateTime.utc(_thisYear, _thisMonth, 31),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              markersMaxCount: 4,
              outsideDaysVisible: false,
              markerDecoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: const Color.fromARGB(255, 225, 255, 0),
                borderRadius: BorderRadius.circular(50),
              ),
              defaultTextStyle:
                  const TextStyle(color: Colors.white, fontSize: 18),
              weekendTextStyle:
                  const TextStyle(color: Colors.grey, fontSize: 18),
              todayTextStyle: const TextStyle(color: Colors.white),
              selectedTextStyle: const TextStyle(color: Colors.black),
              todayDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color.fromARGB(255, 225, 255, 0)),
              ),
              selectedDecoration: const BoxDecoration(
                color: Color.fromARGB(255, 225, 255, 0),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              titleTextFormatter: (date, locale) {
                switch (_thisMonth) {
                  case 1:
                    return "Enero";
                  case 2:
                    return "Febrero";
                  case 3:
                    return "Marzo";
                  case 4:
                    return "Abril";
                  case 5:
                    return "Mayo";
                  case 6:
                    return "Junio";
                  case 7:
                    return "Julio";
                  case 8:
                    return "Agosto";
                  case 9:
                    return "Septiembre";
                  case 10:
                    return "Octubre";
                  case 11:
                    return "Noviembre";
                  case 12:
                    return "Diciembre";
                  default:
                    return "Mes desconocido";
                }
              },
              leftChevronIcon: const Icon(
                Icons.arrow_left,
                color: Colors.white,
              ),
              rightChevronIcon: const Icon(
                Icons.arrow_right,
                color: Colors.white,
              ),
              titleTextStyle:
                  const TextStyle(color: Colors.white, fontSize: 24),
              titleCentered: true,
              formatButtonVisible: false,
            ),
            eventLoader: (date) => _getEventsForDay(date),
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onDaySelected: _onDaySelected,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEventsList(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Eventos',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Lista de eventos
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedEvents.length,
                        itemBuilder: (context, index) {
                          var event = _selectedEvents[index];
                          return GestureDetector(
                            onLongPress: () {
                              if (event['created_by']['_id'] == myUserId) {
                                deleteEvent(event['_id']);
                              } else {
                                print("Borra solo tus eventos");
                              }
                            },
                            child: Card(
                              color: event['type'] == "free"
                                  ? Colors.grey[900]
                                  : primary,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      '$PROFILE_IMG_URL/${event['created_by']['profilePicture'] ?? "$DEFAULT_IMAGE"}'),
                                  radius: 25,
                                ),
                                title: Text(
                                  "Evento ${event['title']}",
                                  style: TextStyle(
                                      color: event['type'] == "free"
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                subtitle: Text(
                                  "Creado por ${event['created_by']['username']}",
                                  style: TextStyle(
                                      color: event['type'] == "free"
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventsList(BuildContext context) {
    if (_selectedEvents.isEmpty) {
      return const Center(
        child: Text(
          "No hay eventos para este día.",
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      // Llamamos a la función que muestra el BottomSheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEventsBottomSheet(context);
      });
      // Retornamos un contenedor vacío ya que el BottomSheet se muestra de manera separada
      return Container();
    }
  }
}
