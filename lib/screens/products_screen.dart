import 'package:flutter/material.dart';
import 'package:izi_frontend/screens/sales_screen.dart';
import 'package:izi_frontend/widgets/add_product_modal.dart';
import 'package:izi_frontend/widgets/edit_product_modal.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _currentPage = 0;
  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  List<Product> _allProducts = [];
  List<Product> _displayedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final fetched = await ProductService.fetchProducts();
    setState(() {
      _allProducts = fetched;
      _displayedProducts = List.from(_allProducts);
      _isLoading = false;
      _applySort();
      _updateDisplayedProducts();
    });
  }

  void _sort<T>(Comparable<T> Function(Product p) getField, int columnIndex,
      bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _applySort();
      _updateDisplayedProducts();
    });
  }

  void _applySort() {
    _allProducts.sort((a, b) {
      final aValue = _getSortValue(a);
      final bValue = _getSortValue(b);
      return _sortAscending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }

  Comparable<dynamic> _getSortValue(Product product) {
    switch (_sortColumnIndex) {
      case 0:
        return product.name;
      case 1:
        return product.description ?? '';
      case 2:
        return product.price;
      case 3:
        return product.stock;
      case 4:
        return product.category ?? '';
      default:
        return product.name;
    }
  }

  void _updateDisplayedProducts() {
    final startIndex = _currentPage * _rowsPerPage;
    var endIndex = startIndex + _rowsPerPage;
    if (endIndex > _allProducts.length) {
      endIndex = _allProducts.length;
    }
    setState(() {
      _displayedProducts = _allProducts.sublist(startIndex, endIndex);
    });
  }

  void _navigateToAddProduct() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: AddProductModal(),
        ),
      ),
    ).then((_) => _loadProducts());
  }

  void _navigateToCreateSale(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SalesScreen()),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await ProductService.deleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado')),
      );
      _loadProducts();
    } catch (e) {
      print('Error al eliminar el producto: $e');
    }
  }

  Widget _buildHeaderCell(String text, int columnIndex,
      {bool numeric = false}) {
    return InkWell(
      onTap: () => _sort(_getSortValue, columnIndex, !_sortAscending),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          mainAxisAlignment:
              numeric ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            if (_sortColumnIndex == columnIndex)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Botones encima de la tabla
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToCreateSale(context),
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Venta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton.icon(
                            onPressed: _navigateToAddProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // Encabezado de la tabla (sin bordes)
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildHeaderCell('Nombre', 0),
                          ),
                          Expanded(
                            flex: 2,
                            child: _buildHeaderCell('Descripción', 1),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildHeaderCell('Precio', 2, numeric: true),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildHeaderCell('Stock', 3, numeric: true),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildHeaderCell('Categoría', 4),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 12),
                              child: Text(
                                'Opciones',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lista de productos (sin bordes entre columnas)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _displayedProducts.length,
                        itemBuilder: (context, index) {
                          final product = _displayedProducts[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Text(
                                      product.description ?? 'N/A',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Text(
                                      product.stock.toString(),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Text(
                                      product.category ?? 'N/A',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue, size: 20),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: EditProductModal(
                                                      product: product),
                                                ),
                                              ),
                                            ).then((_) => _loadProducts());
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red, size: 20),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Confirmar eliminación'),
                                                content: Text(
                                                    '¿Eliminar el producto "${product.name}"?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child:
                                                        const Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      await _deleteProduct(
                                                          product.id);
                                                    },
                                                    style: TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.red),
                                                    child:
                                                        const Text('Eliminar'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Controles de paginación
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _currentPage > 0
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                      _updateDisplayedProducts();
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            'Página ${_currentPage + 1} de ${(_allProducts.length / _rowsPerPage).ceil()}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: (_currentPage + 1) * _rowsPerPage <
                                    _allProducts.length
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                      _updateDisplayedProducts();
                                    });
                                  }
                                : null,
                          ),
                          const SizedBox(width: 20),
                          const Text(
                            'Filas por página:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _rowsPerPage,
                            items: const [
                              DropdownMenuItem(value: 10, child: Text('10')),
                              DropdownMenuItem(value: 20, child: Text('20')),
                              DropdownMenuItem(value: 50, child: Text('50')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _rowsPerPage = value!;
                                _currentPage = 0;
                                _updateDisplayedProducts();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
