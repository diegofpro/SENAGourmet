import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'https://diegopro.com.co';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/loginapp.php'),
      body: {
        'CorreoElectronico': email,
        'Contrasena': password,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recuperar_clave.php'),
      body: {
        'CorreoElectronico': email,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al solicitar recuperación de contraseña');
    }
  }

  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/restablecer_clave.php'),
      body: {
        'token': token,
        'nuevaContrasena': newPassword,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al restablecer la contraseña');
    }
  }
}
