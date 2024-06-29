import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class ApiService {
  static const String baseUrl = 'https://diegopro.com.co/';
  static final Logger logger = Logger();

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login.php'),
      body: {
        'correo_electronico': email,
        'contrasena': password,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      logger.d('Login response: $responseData');
      logger.d('UserId from response: ${responseData['userId']}');
      
      return responseData;
    } else {
      logger.e('Failed to login user: ${response.body}');
      throw Exception('Failed to login user');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserRecipes(String userId) async {
  final response = await http.post(
    Uri.parse('${baseUrl}get_recetas.php'),
    body: {
      'usuario_id': userId,
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception('Failed to load recipes');
  }
}


  static Future<List<dynamic>> getCategorias() async {
    final response = await http.get(Uri.parse('${baseUrl}get_categories.php'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      logger.e('Failed to load categories: ${response.body}');
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<dynamic>> getEtiquetas() async {
    final response = await http.get(Uri.parse('${baseUrl}get_tags.php'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      logger.e('Failed to load tags: ${response.body}');
      throw Exception('Failed to load tags');
    }
  }

  static Future<Map<String, dynamic>> createRecipe(
    String userId,
    String titulo,
    String descripcion,
    String tiempoPreparacion,
    String ingredientes,
    String categoriaId,
    List<String> etiquetaIds,
    String imagePath,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}create_recipe.php'));

    request.fields['titulo'] = titulo;
    request.fields['descripcion'] = descripcion;
    request.fields['tiempo_preparacion'] = tiempoPreparacion;
    request.fields['ingredientes'] = ingredientes;
    request.fields['categoria_id'] = categoriaId;
    request.fields['etiqueta_ids'] = jsonEncode(etiquetaIds);
    request.fields['usuario_id'] = userId;

    if (imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('imagen', imagePath));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      var responseData = await response.stream.bytesToString();
      logger.e('Failed to create recipe: $responseData');
      throw Exception('Failed to create recipe');
    }
  }
}
