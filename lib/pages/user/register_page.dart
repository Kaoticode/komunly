import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/utils/shape_clippers.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:http/http.dart' as http;

class RegistePage extends StatefulWidget {
  const RegistePage({super.key});

  @override
  State<RegistePage> createState() => _RegistePageState();
}

class _RegistePageState extends State<RegistePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String registerText = "Regístrate";
        bool obscure = true;

  void _register() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showSnackMessage(
          context, "Rellena todos los datos para continuar", "WARNING");
      return;
    }

    if (password != confirmPassword) {
      showSnackMessage(context, "Las contraseñas no coinciden", "WARNING");
      return;
    }
    setState(() {
      registerText = "Registrando...";
    });
    String apiUrl = "$API_URL/auth/register";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 201) {
        showSnackMessage(context,
            "Registro exitoso. Inicia sesión para continuar", "SUCCESS");
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    } finally {
      setState(() {
        registerText = "Regístrarse";
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
          "Regístrate para continuar",
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
              children: <Widget>[Text("Email")],
            ),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                suffixIcon: Icon(
                  Icons.mail,
                  color: iconTheme.color,
                  size: 20,
                ),
                hintText: "Email",
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
              obscureText: obscure,
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
              controller: _confirmPasswordController,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                   onTap: changePasswordType,
                  child:Icon(
                    obscure ? Icons.lock : Icons.lock_open,
                    color: Theme.of(context).iconTheme.color,
                    size: 20,
                  ),
                ),
                hintText: "Confirmar contraseña",
                hintStyle: const TextStyle(color: Color(0xFFFFFFFF)),
              ),
              obscureText: obscure,
            ),
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
       
        GestureDetector(
          onTap: _register,
          child: Text(registerText),
        ),
        const SizedBox(
          height: 20.0,
        ),
        InkWell(
          onTap: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        ),
          child: Text(
            "¿Ya tienes cuenta? Inicia sesión",
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
