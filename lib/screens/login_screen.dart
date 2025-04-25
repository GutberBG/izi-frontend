import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:izi_frontend/screens/home_screen.dart';

const users = {
  'demo@gmail.com': '123456',
};

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    debugPrint('Nombre: ${data.name}, Contraseña: ${data.password}');
    await Future.delayed(loginTime);
    if (!users.containsKey(data.name)) {
      return 'Usuario no encontrado';
    }
    if (users[data.name] != data.password) {
      return 'Contraseña incorrecta';
    }
    return null;
  }

  Future<String?> _signupUser(SignupData data) async {
    await Future.delayed(loginTime);
    return null; // sin validación para demo
  }

  Future<String?> _recoverPassword(String name) async {
    await Future.delayed(loginTime);
    return users.containsKey(name) ? null : 'Usuario no encontrado';
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'IZI VENTAS',
      onLogin: _authUser,
      onSignup: _signupUser,
      onRecoverPassword: _recoverPassword,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(user: {
              'name': 'Demo User',
              'email': 'demo@gmail.com',
              'avatar': 'https://i.pravatar.cc/150?img=5',
            }),
          ),
        );
      },
      theme: LoginTheme(
        primaryColor: Colors.blue[400]!,
        accentColor: Colors.white,
        errorColor: Colors.deepOrange,
      ),
    );
  }
}
