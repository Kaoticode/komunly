import 'package:crypto/repository/user.repository.dart';
import 'package:crypto/screen/Bottom_Nav_Bar/bottom_nav_bar.dart';
import 'package:crypto/screen/home/home.dart';
import 'package:crypto/screen/intro/login.dart';
import 'package:crypto/screen/setting/themes.dart';
import 'package:crypto/utils/constants.dart';
import 'package:crypto/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:crypto/component/style.dart';

class signUp extends StatefulWidget {
  ThemeBloc? themeBloc;
  signUp({this.themeBloc});
  @override
  _signUpState createState() => _signUpState(themeBloc);
}

class _signUpState extends State<signUp> {
  late String errorMessage = '';
  ThemeBloc? _themeBloc;
  _signUpState(this._themeBloc);
  final TextEditingController _nieController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordConfirmController= TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,

        /// Set Background image in splash screen layout (Click to open code)
        decoration: BoxDecoration(color: colorStyle.background),
        child: Stack(
          children: <Widget>[
            ///
            /// Set image in top
            ///
            Container(
              height: 129.0,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/image/signupHeader.png"),
                      fit: BoxFit.cover)),
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    /// Animation text marketplace to choose Login with Hero Animation (Click to open code)
                    Padding(
                      padding:
                          EdgeInsets.only(top: mediaQuery.padding.top + 130.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 17.0, top: 7.0),
                            child: Text(
                              "weBuild",
                              style: TextStyle(
                                  fontFamily: "Sans",
                                  color: Colors.white,
                                  fontSize: 27.0,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 3.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 40.0),
                      child: _buildTextFeild(
                          widgetIcon: Icon(
                            Icons.people,
                            color: colorStyle.primaryColor,
                            size: 20,
                          ),
                          controller: _userNameController,
                          hint: 'User Name',
                          obscure: false,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start),
                    ),
                     Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 40.0),
                      child: _buildTextFeild(
                          widgetIcon: Icon(
                            Icons.people,
                            color: colorStyle.primaryColor,
                            size: 20,
                          ),
                          controller: _phoneController,
                          hint: 'Telefono',
                          obscure: false,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 40.0),
                      child: _buildTextFeild(
                          widgetIcon: Icon(
                            Icons.people,
                            color: colorStyle.primaryColor,
                            size: 20,
                          ),
                          controller: _nieController,
                          hint: 'DNI/NIE',
                          obscure: false,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 20.0),
                      child: _buildTextFeild(
                          widgetIcon: Icon(
                            Icons.email,
                            color: colorStyle.primaryColor,
                            size: 20,
                          ),
                          controller: _emailController,
                          hint: 'Email de recuperación',
                          obscure: false,
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.start),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 20.0),
                      child: _buildTextFeild(
                          widgetIcon: Icon(
                            Icons.vpn_key,
                            size: 20,
                            color: colorStyle.primaryColor,
                          ),
                          controller: _passwordController,
                          hint: 'Contraseña',
                          obscure: true,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 20.0),
                      child: _buildTextFeild(
                          widgetIcon: Icon(
                            Icons.vpn_key,
                            size: 20,
                            color: colorStyle.primaryColor,
                          ),
                          controller: _passwordConfirmController,
                          hint: 'Confirmar contraseña',
                          obscure: true,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start),
                    ),
                    Text(
                        errorMessage,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Constants.errorColor,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 40.0),
                      child: GestureDetector(
                        onTap: () async {
                          if ((_userNameController.text?.length ?? 0) > 0 && (_nieController.text?.length ?? 0) > 0 && (_passwordController.text?.length ?? 0) > 0 && (_emailController.text?.length ?? 0) > 0 && (_phoneController.text?.length ?? 0) > 0) {
                              if(_passwordConfirmController.text == _passwordController.text){
                                final response = await createUser({
                                  'dni': _nieController.text,
                                  'password': _passwordController.text,
                                  'email': _emailController.text,
                                  'fullname': _userNameController.text,
                                  'phone': _phoneController.text
                                });
                                if (await response) {
                                  // ignore: use_build_context_synchronously
                                  Helper.nextScreen(context, home());
                                }
                              } else {
                              setState(() {
                                errorMessage = 'Las contraseñas deben ser iguales';
                              });
                            }
                              
                          } else {
                            setState(() {
                              errorMessage = 'Completa el formulario';
                            });
                          }
                          /*Navigator.of(context)
                              .pushReplacement(PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => bottomNavBar(
                                        themeBloc: _themeBloc,
                                      )));*/
                        },
                        child: Container(
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(0.0)),
                            color: colorStyle.primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              "Finalizar",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20.0,
                                  letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          Helper.nextScreen(context, Login(
                                        themeBloc: _themeBloc,
                                      ));
                        },
                        child: Container(
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(0.0)),
                            border: Border.all(
                              color: colorStyle.primaryColor,
                              width: 0.35,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Iniciar sesión",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 17.5,
                                  letterSpacing: 1.9),
                            ),
                          ),
                        ),
                      ),
                    ),
//                  Padding(
//                    padding: const EdgeInsets.only(left:20.0,right: 20.0,bottom: 15.0),
//                    child: Container(width: double.infinity,height: 0.15,color: colorStyle.primaryColor,),
//                  ),
//                  Text("Register",style: TextStyle(color: colorStyle.primaryColor,fontSize: 17.0,fontWeight: FontWeight.w800),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFeild({
    String? hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
    required bool obscure,
    String? icon,
    required TextAlign textAlign,
    Widget? widgetIcon,
  }) {
    return Column(
      children: <Widget>[
        Container(
          height: 53.5,
          decoration: BoxDecoration(
            color: Colors.black26,
//              color: Color(0xFF282E41),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            border: Border.all(
              color: colorStyle.primaryColor,
              width: 0.15,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0),
            child: Theme(
              data: ThemeData(hintColor: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextField(
                  style: new TextStyle(color: Colors.white),
                  textAlign: textAlign,
                  obscureText: obscure,
                  controller: controller,
                  keyboardType: keyboardType,
                  autocorrect: false,
                  autofocus: false,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: widgetIcon,
                      ),
                      contentPadding: EdgeInsets.all(0.0),
                      filled: true,
                      fillColor: Colors.transparent,
                      labelText: hint,
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(
                        color: Colors.white70,
                      )),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
