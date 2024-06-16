import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/gambling_page.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/widgets/customTile.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:komunly/widgets/transactionsList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController _bankNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  final scrollController = ScrollController();
  List<dynamic> transactions = [];
  int userBalance = 0;
  String myUserId = "";
  int page = 1;
  int limit = 15;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchUserId();
    fetchUserBalance();
    fetchTransactions();
  }

  void fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myUserId = prefs.getString('user_id') ?? '0';
    });
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

  void sendMoney() async {
    String bankNumber = _bankNumberController.text;
    String amount = _amountController.text;
    String concept = _conceptController.text;
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
        body: jsonEncode({
          "sender": myUserId,
          "receiver": bankNumber,
          "amount": amount,
          "concept": concept,
          "transactionType": "TRANSFERENCE"
        }),
      );

      if (response.statusCode == 201) {
        fetchUserBalance();
        showSnackMessage(context, "Transacción realizada con éxito", "SUCCESS");
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

  void fetchTransactions() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/transactions?page=$page&limit=$limit";

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
        List<dynamic> newData = jsonResponse['data'];

        setState(() {
          transactions.addAll(newData);
        });
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        refreshTokens();
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    } finally {
      setState(() {
        isLoading = false;
      });
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
                fetchUserId();
    fetchUserBalance();
    fetchTransactions();
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

  void openSendBottom(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.black,
      isScrollControlled: true, // Makes the bottom sheet take up more space
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.9, // Adjust the height to take up the entire screen
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Send Message',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _bankNumberController,
                    decoration: const InputDecoration(
                      hintText: 'Introduce el número bancario del destinatario',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      hintText: 'Introduce la cantidad a enviar',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _conceptController,
                    decoration: const InputDecoration(
                      hintText: 'Introduce un concepto (opcional)',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      sendMoney();
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
                          'Enviar Dinero',
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Transacciones",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leadingWidth: 30,
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 80,
            child: Center(
              child: Text(
                '${userBalance.toString()}\$',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomTile(
                  icon: Icons.near_me,
                  title: "Enviar",
                  onTap: () {
                    openSendBottom(context);
                  },
                ),
                CustomTile(
                  icon: Icons.money,
                  title: "Jugar",
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const GamblingPage()));
                  },
                ),
                CustomTile(
                  icon: Icons.attach_money,
                  title: "Tareas",
                  onTap: () {},
                ),
                CustomTile(
                  icon: Icons.qr_code,
                  title: "QR",
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Transacciones",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: const Text(
                    "See all",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                controller: scrollController,
                itemCount: transactions.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < transactions.length) {
                    return TransactionsList(
                        transaction: transactions[index], myUserId: myUserId);
                  } else {
                    return _buildLoader();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollListener() {
    if (!isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      page++;
      fetchTransactions();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget _buildLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        color: Colors.grey[900],
        shape: const RoundedRectangleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
