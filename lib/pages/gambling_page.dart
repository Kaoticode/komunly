import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:http/http.dart' as http;
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/moneda.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:komunly/widgets/tablero.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamblingPage extends StatefulWidget {
  static const String id = "/gambling";

  const GamblingPage({super.key});

  @override
  State<GamblingPage> createState() => _GamblingPageState();
}

class _GamblingPageState extends State<GamblingPage> {
  final selected = BehaviorSubject<int>();
  late int allIn = 0;
  int userBalance = 0;
  int rouletteNumbers = 5;
  final Map<int, List<int>> totalBetMap = {};
  final List<int> selectedNumbers = [];

  @override
  void initState() {
    super.initState();
    fetchUserBalance();
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  void fetchUserBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/users/getBalance";

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
        userBalance = jsonResponse['userBalance'];
        allIn = userBalance;
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

  Future<void> updateBalanceInDatabase(
      int totalBet, String type, String transactionText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? myUserId = prefs.getString('user_id');
    String apiUrl = "$API_URL/transactions";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          "amount": totalBet,
          "transactionType": type,
          "concept": transactionText,
          "sender": myUserId,
        }),
      );

      if (response.statusCode == 201) {
        fetchUserBalance();
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
                fetchUserBalance();
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

  int getTotalBetAmount() {
    return totalBetMap.values.expand((bets) => bets).fold(0, (a, b) => a + b);
  }

  void handleSpin() async {
    final totalBet = getTotalBetAmount();
    if (totalBet > 0) {
      final selectedValue = Fortune.randomInt(0, rouletteNumbers);
      setState(() {
        selected.add(selectedValue);
        userBalance -= totalBet;
        updateBalanceInDatabase(totalBet, "CHARGE", "Perdida en casino");
      });
      final totalWin = calculateTotalWin(selectedValue);
      Future.delayed(const Duration(seconds: 5), () {
        showResultSnackBar(totalWin);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, selecciona una apuesta antes de girar."),
        ),
      );
    }
  }

  void deleteBets() {
    setState(() {
      selectedNumbers.clear();
      totalBetMap.clear();
    });
  }

  int calculateTotalWin(int selectedValue) {
    int totalWin = 0;
    totalBetMap.forEach((number, bets) {
      if (number == selectedValue) {
        totalWin += bets.fold(0, (a, b) => a + b) * (rouletteNumbers - 1);
      }
    });
    return totalWin;
  }

  void showResultSnackBar(int totalWin) {
    if (totalWin > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Has acertado! Ganaste $totalWin Euros."),
        ),
      );
      updateBalanceInDatabase(totalWin, "DEPOSIT", "Ganancia en casino");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Oops! No has acertado. Inténtalo de nuevo."),
        ),
      );
    }
  }

  void handleNumberSelection(int number) {
    setState(() {
      if (selectedNumbers.contains(number)) {
        selectedNumbers.remove(number);
      } else {
        selectedNumbers.add(number);
      }
    });
  }

  void handleBet(int value) {
    final totalBet = getTotalBetAmount();
    if (userBalance >= totalBet + value) {
      setState(() {
        if (selectedNumbers.isNotEmpty) {
          for (final number in selectedNumbers) {
            totalBetMap[number] = (totalBetMap[number] ?? [])..add(value);
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No tienes suficiente saldo para hacer esa apuesta."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<int> betValues = [1, 5, 10, 50, 100, allIn];
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: FortuneWheel(
                selected: selected.stream,
                animateFirst: false,
                items: List.generate(
                  rouletteNumbers,
                  (index) => FortuneItem(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        index.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                onAnimationEnd: fetchUserBalance,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Balance: $userBalance €",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              "Apuesta total: ${getTotalBetAmount()} €",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                rouletteNumbers,
                (index) => GestureDetector(
                  onTap: () => handleNumberSelection(index),
                  child: Tablero(
                    number: index,
                    color: index % 2 == 0 ? 'red' : 'black',
                    isSelected: selectedNumbers.contains(index),
                    betAmount:
                        totalBetMap[index]?.fold(0, (a, b) => a! + b) ?? 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int value in betValues)
                  GestureDetector(
                    onTap: () => handleBet(value),
                    child: Moneda(number: value),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                handleSpin();
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Girar',
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
            GestureDetector(
                onTap: () {
                  deleteBets();
                },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Eliminar Apuesta",
                      style: TextStyle(color: red, fontSize: 16)),
                )),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
