import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class EditProductModal extends StatefulWidget {
  final Product product;

  const EditProductModal({super.key, required this.product});

  @override
  State<EditProductModal> createState() => _EditProductModalState();
}

class _EditProductModalState extends State<EditProductModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  late TextEditingController _supplierController;
  DateTime? _expirationDate;
  String? _selectedCategory;

  final List<String> _categories = ['Comida', 'Electrónica', 'Hogar', 'Ropa', 'Limpieza'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _categoryController = TextEditingController(text: widget.product.category);
    _supplierController = TextEditingController(text: widget.product.supplier);
    _expirationDate = widget.product.expirationDate;
    _selectedCategory = widget.product.category;
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      final updatedProduct = Product(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _categoryController.text,
        supplier: _supplierController.text,
        expirationDate: _expirationDate,
        image: widget.product.image,
        id: widget.product.id,
      );

      try {
        await ProductService.updateProduct(widget.product.id, updatedProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado exitosamente')),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        print('Error al actualizar el producto: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Wrap(
            runSpacing: 10,
            children: [
              const Text("Editar Producto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed < 0) return 'Debe ser un número válido';
                  return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 0) return 'Debe ser un número entero válido';
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
                validator: (value) => value == null || value.isEmpty ? 'Selecciona una categoría' : null,
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
                        initialDate: _expirationDate ?? DateTime.now(),
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
                onPressed: _updateProduct,
                child: const Text('Actualizar'),
              ),
            ],
          ),
        ),
    );
  }
}
