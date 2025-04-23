import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class AddProductModal extends StatefulWidget {
  const AddProductModal({super.key});

  @override
  State<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  final _supplierController = TextEditingController();
  DateTime? _expirationDate;

  final List<String> _categories = [
    'Comida',
    'Electrónica',
    'Hogar',
    'Ropa',
    'Limpieza'
  ];
  String? _selectedCategory;

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _categoryController.text,
        supplier: _supplierController.text,
        expirationDate: _expirationDate,
        image: '', id: '', // puedes dejarlo vacío por ahora
      );

      try {
        await ProductService.createProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto guardado exitosamente')),
        );
        // Aquí puedes agregar lógica para actualizar la lista de productos en la pantalla principal

        Navigator.of(context).pop(true); // indica que se creó correctamente
      } catch (e) {
        //imprimir error en consola
        print('Error al guardar el producto: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 10,
          children: [
            const Text("Agregar Producto",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requerido';
                final parsed = double.tryParse(value);
                if (parsed == null || parsed < 0)
                  return 'Debe ser un número válido';
                return null;
              },
            ),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requerido';
                final parsed = int.tryParse(value);
                if (parsed == null || parsed < 0)
                  return 'Debe ser un número entero válido';
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _categoryController.text = value ?? '';
                });
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'Selecciona una categoría'
                  : null,
            ),
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(labelText: 'Proveedor'),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(_expirationDate == null
                      ? 'Sin fecha de expiración'
                      : 'Expira: ${_expirationDate!.toLocal().toString().split(' ')[0]}'),
                ),
                TextButton(
                  child: const Text("Elegir Fecha"),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _expirationDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _saveProduct,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
