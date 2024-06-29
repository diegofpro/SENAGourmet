import 'package:flutter/material.dart';
import 'package:gourmet/services/api_service.dart';
import 'create_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class RecipeFilterScreen extends StatefulWidget {
  final String userId;
  const RecipeFilterScreen({super.key, required this.userId});

  @override
  RecipeFilterScreenState createState() => RecipeFilterScreenState();
}

class RecipeFilterScreenState extends State<RecipeFilterScreen> {
  List<Map<String, dynamic>> recipes = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    try {
      final loadedRecipes = await ApiService.getUserRecipes(widget.userId);
      setState(() {
        recipes = loadedRecipes;
      });
    } catch (e) {
      debugPrint('Error loading recipes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar las recetas: $e')),
        );
      }
    }
  }

  void _logout() {
    // Implementa tu lógica de cierre de sesión aquí
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recetas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar recetas',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Implementar la lógica de búsqueda aquí
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      Image.network(
                        'https://diegopro.com.co/uploads/uno.jpg',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recipes[index]['Titulo'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recipes[index]['Descripcion'].split(' ').take(10).join(' '),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(recipe: recipes[index]),
                            ),
                          );
                        },
                        child: const Text('Ver más'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    // Ya estamos en Mis recetas
                  },
                  child: const Text('Mis recetas'),
                ),
                const SizedBox(width: 8.0), // Espacio entre botones
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateRecipeScreen(userId: widget.userId),
                      ),
                    );
                  },
                  child: const Text('Crear Receta'),
                ),
                const SizedBox(width: 8.0), // Espacio entre botones
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _logout,
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
