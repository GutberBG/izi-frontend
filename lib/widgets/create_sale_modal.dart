import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/product_service.dart';
import '../services/sales_service.dart';

class CreateSaleModal extends StatefulWidget {
  const CreateSaleModal({super.key});

  @override
  State<CreateSaleModal> createState() => _CreateSaleModalState();
}

class _CreateSaleModalState extends State<CreateSaleModal> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _noteController = TextEditingController();
  List<SaleItem> _selectedItems = [];
  List<Product> _availableProducts = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
  try {
    final result = await ProductService.fetchProducts();
    setState(() {
      _availableProducts = result.products;
      _isLoadingProducts = false;
    });
  } catch (e) {
    setState(() => _isLoadingProducts = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error cargando productos: $e')),
    );
  }
}

  double get _totalAmount {
    return _selectedItems.fold(0, (sum, item) {
      final product = _availableProducts.firstWhere(
        (p) => p.id == item.product,
        orElse: () => Product(
          id: '',
          name: 'Producto eliminado',
          price: 0,
          stock: 0,
          category: '',
          description: '',
          isDeleted: false,
        ),
      );
      return sum + (product.price * item.quantity);
    });
  }

  Future<void> _saveSale() async {
    if (_formKey.currentState!.validate() && _selectedItems.isNotEmpty) {
      try {
        await SalesService.createSale(
          items: _selectedItems,
          note: _noteController.text,
          user: _clientNameController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta registrada exitosamente')),
        );

        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        print('Error guardando la venta: $e');
        if (mounted) Navigator.of(context).pop(true);
      }
    } else if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un producto')),
      );
    }
  }

  void _addProductToSale(Product product) {
    setState(() {
      final existingIndex = _selectedItems.indexWhere(
        (item) => item.product == product.id,
      );

      if (existingIndex >= 0) {
        // Si el producto ya está en la lista, aumentamos la cantidad
        final existingItem = _selectedItems[existingIndex];
        final newQuantity = existingItem.quantity + 1;
        final newSubtotal = product.price * newQuantity;

        final updatedItem = existingItem.copyWith(
          quantity: newQuantity,
          subtotal: newSubtotal,
        );
        _selectedItems[existingIndex] = updatedItem;
      } else {
        // Si es un producto nuevo, lo agregamos con cantidad 1
        _selectedItems.add(SaleItem(
          product: product.id,
          quantity: 1,
          unitPrice: product.price,
          subtotal: product.price * 1, // Calculamos el subtotal inicial
        ));
      }
    });
  }

  void _updateItemQuantity(SaleItem item, int newQuantity) {
    if (newQuantity <= 0) {
      setState(() => _selectedItems.remove(item));
      return;
    }

    setState(() {
      final index = _selectedItems.indexWhere((i) => i.product == item.product);
      if (index >= 0) {
        _selectedItems[index] = item.copyWith(quantity: newQuantity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Registrar Nueva Venta",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Sección de información del cliente
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Sección de productos disponibles
              const Text(
                'Productos Disponibles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _isLoadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : _availableProducts.isEmpty
                      ? const Text('No hay productos disponibles')
                      : SizedBox(
                          height: 140,
                          child: GridView.builder(
                            scrollDirection: Axis.horizontal,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 0.5,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _availableProducts.length,
                            itemBuilder: (context, index) {
                              final product = _availableProducts[index];
                              return Card(
                                child: InkWell(
                                  onTap: () => _addProductToSale(product),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Bs. ${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: Colors.green),
                                        ),
                                        Text(
                                          'Stock: ${product.stock}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
              const SizedBox(height: 20),

              // Sección de productos seleccionados
              const Text(
                'Productos en la Venta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _selectedItems.isEmpty
                  ? const Center(
                      child: Text('No hay productos seleccionados'),
                    )
                  : Column(
                      children: _selectedItems.map((item) {
                        final product = _availableProducts.firstWhere(
                          (p) => p.id == item.product,
                          orElse: () => Product(
                            id: '',
                            name: 'Producto no encontrado',
                            price: 0,
                            stock: 0,
                            category: '',
                            description: '',
                            isDeleted: false,
                          ),
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Bs. ${product.price.toStringAsFixed(2)} c/u',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => _updateItemQuantity(
                                        item,
                                        item.quantity - 1,
                                      ),
                                    ),
                                    Text(item.quantity.toString()),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _updateItemQuantity(
                                        item,
                                        item.quantity + 1,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _updateItemQuantity(
                                        item,
                                        0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

              // Total de la venta
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Bs. ${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Observaciones
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Guardar Venta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
