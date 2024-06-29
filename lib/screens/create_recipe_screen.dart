import 'package:flutter/material.dart';
import 'package:gourmet/services/api_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  final String userId;

  const CreateRecipeScreen({super.key, required this.userId});

  @override
  CreateRecipeScreenState createState() => CreateRecipeScreenState();
}

class CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _tiempoPreparacionController = TextEditingController();
  final _ingredientesController = TextEditingController();
  final _etiquetasController = TextEditingController();

  List<dynamic> _categorias = [];
  String? _selectedCategoria;
  final List<String> _selectedEtiquetas = [];

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
  }

  Future<void> _fetchCategorias() async {
    try {
      var categorias = await ApiService.getCategorias();
      if (mounted) {
        setState(() {
          _categorias = categorias;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener las categorías')),
        );
      }
    }
  }

  Future<void> _createRecipe() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await ApiService.createRecipe(
          widget.userId,
          _tituloController.text,
          _descripcionController.text,
          _tiempoPreparacionController.text,
          _ingredientesController.text,
          _selectedCategoria ?? '',
          _selectedEtiquetas,
          '', // No se enviará una imagen
        );

        if (!mounted) return;

        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en la conexión con el servidor')),
        );
      }
    }
  }

  void _addEtiqueta(String etiqueta) {
    setState(() {
      _selectedEtiquetas.add(etiqueta);
    });
    _etiquetasController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Receta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduzca el título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduzca la descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tiempoPreparacionController,
                  decoration: const InputDecoration(labelText: 'Tiempo de Preparación'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduzca el tiempo de preparación';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ingredientesController,
                  decoration: const InputDecoration(labelText: 'Ingredientes'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduzca los ingredientes';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategoria,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: _categorias.map<DropdownMenuItem<String>>((categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria['CategoriaID'].toString(),
                      child: Text(categoria['Nombre']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoria = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione una categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _etiquetasController,
                  decoration: const InputDecoration(labelText: 'Etiquetas'),
                  onFieldSubmitted: (value) {
                    if (value.isNotEmpty && !_selectedEtiquetas.contains(value)) {
                      _addEtiqueta(value);
                    }
                  },
                ),
                Wrap(
                  spacing: 8.0,
                  children: _selectedEtiquetas.map((etiqueta) {
                    return Chip(
                      label: Text(etiqueta),
                      onDeleted: () {
                        setState(() {
                          _selectedEtiquetas.remove(etiqueta);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _createRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Color de fondo naranja
                    foregroundColor: Colors.white, // Color del texto blanco
                    minimumSize: const Size(double.infinity, 48), // Ancho completo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Crear Receta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
