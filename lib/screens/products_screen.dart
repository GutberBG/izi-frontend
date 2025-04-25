import 'package:flutter/material.dart';
import 'package:izi_frontend/screens/sales_screen.dart';
import 'package:izi_frontend/widgets/add_product_modal.dart';
import 'package:izi_frontend/widgets/edit_product_modal.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with SingleTickerProviderStateMixin {
  int _currentPage = 1; // Cambiado a 1 para alinearse con la API (empezando en 1, no en 0)
  int _rowsPerPage = 10;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  late AnimationController _animationController;

  List<Product> _displayedProducts = [];
  int _totalProducts = 0;
  int _totalPages = 0;
  bool _isLoading = true;

  // Filtros
  String? _nameFilter;
  String? _categoryFilter;
  String? _supplierFilter;
  double? _minPriceFilter;
  double? _maxPriceFilter;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await ProductService.fetchProducts(
        page: _currentPage,
        limit: _rowsPerPage,
        name: _nameFilter,
        category: _categoryFilter,
        supplier: _supplierFilter,
        minPrice: _minPriceFilter,
        maxPrice: _maxPriceFilter,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
      
      setState(() {
        _displayedProducts = result.products;
        _totalProducts = result.totalProducts;
        _totalPages = result.totalPages;
        _isLoading = false;
      });
      
      // Reiniciar animaciones cuando se cargan nuevos datos
      _animationController.reset();
      _animationController.forward();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $error')),
      );
    }
  }

  void _sort(String field, int columnIndex) {
    setState(() {
      if (_sortBy == field) {
        // Si ya estamos ordenando por este campo, cambiamos la dirección
        _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
      } else {
        // Si es un nuevo campo, establecemos el campo y dirección por defecto
        _sortBy = field;
        _sortOrder = 'asc';
      }
      _loadProducts(); // Recarga los productos con el nuevo orden
    });
  }

  void _navigateToAddProduct() {
    showDialog(
      context: context,
      builder: (context) => AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 400),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: AddProductModal(),
              ),
            ),
          ),
        ),
      ),
    ).then((_) => _loadProducts());
  }

  void _navigateToCreateSale(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: SalesScreen(),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await ProductService.deleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AnimationConfiguration.synchronized(
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: const Text('Producto eliminado'),
              ),
            ),
          ),
        ),
      );
      _loadProducts();
    } catch (e) {
      print('Error al eliminar el producto: $e');
    }
  }

  Widget _buildHeaderCell(String text, String field, int columnIndex,
      {bool numeric = false}) {
    final isSorted = _sortBy == field;
    return InkWell(
      onTap: () => _sort(field, columnIndex),
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
            if (isSorted)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  _sortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.white,
                  key: ValueKey<bool>(_sortOrder == 'asc'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Método para construir los filtros
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 600),
        child: SlideAnimation(
          horizontalOffset: -100.0,
          child: FadeInAnimation(
            child: Card(
              elevation: 2,
              child: ExpansionTile(
                title: Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                onChanged: (value) {
                                  _nameFilter = value.isEmpty ? null : value;
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Categoría',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                onChanged: (value) {
                                  _categoryFilter = value.isEmpty ? null : value;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Precio mínimo',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _minPriceFilter = value.isEmpty ? null : double.tryParse(value);
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Precio máximo',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _maxPriceFilter = value.isEmpty ? null : double.tryParse(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Restablecer filtros
                                setState(() {
                                  _nameFilter = null;
                                  _categoryFilter = null;
                                  _supplierFilter = null;
                                  _minPriceFilter = null;
                                  _maxPriceFilter = null;
                                  _currentPage = 1;
                                });
                                _loadProducts();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[300],
                              ),
                              child: Text('Limpiar'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                _currentPage = 1; // Volver a la primera página al filtrar
                                _loadProducts();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: Text('Aplicar filtros'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Colors.blue.shade700,
        // color texto blanco
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoading
          ? Center(
              child: AnimationConfiguration.synchronized(
                duration: const Duration(milliseconds: 600),
                child: ScaleAnimation(
                  scale: 0.5,
                  child: FadeInAnimation(
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
            )
          : Center(
              child: AnimationConfiguration.synchronized(
                duration: const Duration(milliseconds: 400),
                child: FadeInAnimation(
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                
                          // Botones encima de la tabla con animaciones
                          AnimationConfiguration.synchronized(
                            duration: const Duration(milliseconds: 600),
                            child: SlideAnimation(
                              horizontalOffset: -100.0,
                              child: FadeInAnimation(
                                child: Row(
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
                              ),
                            ),
                          ),
                
                          const SizedBox(height: 12),
                
                          // Filtros
                          _buildFilters(),
                
                          const SizedBox(height: 16),
                          // Encabezado de la tabla con animación
                          AnimationConfiguration.synchronized(
                            duration: const Duration(milliseconds: 600),
                            child: SlideAnimation(
                              verticalOffset: -50.0,
                              child: FadeInAnimation(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _buildHeaderCell('Nombre', 'name', 0),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: _buildHeaderCell('Descripción', 'description', 1),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: _buildHeaderCell('Precio', 'price', 2, numeric: true),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: _buildHeaderCell('Stock', 'stock', 3, numeric: true),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: _buildHeaderCell('Categoría', 'category', 4),
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
                              ),
                            ),
                          ),
                          // Lista de productos con animaciones escalonadas
                          Expanded(
                            child: AnimationLimiter(
                              child: ListView.builder(
                                itemCount: _displayedProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _displayedProducts[index];
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 400),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Container(
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
                                                              child: AnimationConfiguration.synchronized(
                                                                duration: const Duration(milliseconds: 400),
                                                                child: SlideAnimation(
                                                                  verticalOffset: 50.0,
                                                                  child: FadeInAnimation(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(
                                                                          16.0),
                                                                      child: EditProductModal(
                                                                          product: product),
                                                                    ),
                                                                  ),
                                                                ),
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
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Controles de paginación con animación
                          AnimationConfiguration.synchronized(
                            duration: const Duration(milliseconds: 600),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Container(
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
                                        onPressed: _currentPage > 1
                                            ? () {
                                                setState(() {
                                                  _currentPage--;
                                                  _loadProducts();
                                                });
                                              }
                                            : null,
                                      ),
                                      Text(
                                        'Página $_currentPage de $_totalPages',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: _currentPage < _totalPages
                                            ? () {
                                                setState(() {
                                                  _currentPage++;
                                                  _loadProducts();
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
                                            _currentPage = 1; // Volver a la primera página
                                            _loadProducts();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}