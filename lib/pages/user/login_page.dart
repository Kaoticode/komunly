import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/register_page.dart';
import 'package:komunly/pages/root_app.dart';
import 'package:komunly/utils/shape_clippers.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String loginText = "Iniciar Sesión";
  bool obscure = true;

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      showSnackMessage(
          context, "Rellena todos los datos para continuar", "WARNING");
      return;
    }
    setState(() {
      loginText = "Iniciando sesión...";
    });
    String apiUrl = "$API_URL/auth/login";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        String userId = jsonResponse['user_id'];
        String accessToken = jsonResponse['access_token'];
        String refreshToken = jsonResponse['refresh_token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RootPage()),
        );
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      print("Error de conexión: $e");
    } finally {
      setState(() {
        loginText = "Iniciar sesión";
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var heightOfScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: ClipPath(
                clipper: CustomLoginShapeClipper2(),
                child: Container(
                  height: heightOfScreen,
                  decoration: const BoxDecoration(color: Color(0xFFDAD0D3)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: ClipPath(
                clipper: CustomLoginShapeClipper1(),
                child: Container(
                  height: heightOfScreen,
                  decoration: const BoxDecoration(color: Color(0xFFC2366D)),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 36),
              child: ListView(
                children: <Widget>[
                  SizedBox(height: heightOfScreen * 0.075),
                  _buildIntroText(context),
                  const SizedBox(
                    height: 8.0,
                  ),
                  _buildForm(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroText(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var heightOfScreen = MediaQuery.of(context).size.height;

    return ListBody(
      children: <Widget>[
        Text(
          "Bienvendo a Komunly",
          style: textTheme.displaySmall?.copyWith(
            color: const Color(0xFFFFFFFF),
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          "Inicia sesión para continuar",
          style: textTheme.bodyLarge?.copyWith(
            color: const Color(0xFFFFFFFF),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: heightOfScreen * 0.075),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var iconTheme = Theme.of(context).iconTheme;

    void changePasswordType() {
      setState(() {
        obscure = !obscure;
      });
    }

    return Column(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[Text("Username")],
            ),
            TextFormField(
              controller: _usernameController,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                suffixIcon: Icon(
                  Icons.person,
                  color: iconTheme.color,
                  size: 20,
                ),
                hintText: "Username",
                hintStyle: const TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[Text("Contraseña")],
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: obscure,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: changePasswordType,
                  child: Icon(
                    obscure ? Icons.lock : Icons.lock_open,
                    color: Theme.of(context).iconTheme.color,
                    size: 20,
                  ),
                ),
                hintText: "Contraseña",
                hintStyle: const TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
        GestureDetector(
          onTap: _login,
          child: Text(loginText),
        ),
        const SizedBox(
          height: 20.0,
        ),
        InkWell(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RegistePage()),
          ),
          child: Text(
            "¿No tienes cuenta? Regístrate",
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 14.0,
              color: const Color(0xFF51515E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
