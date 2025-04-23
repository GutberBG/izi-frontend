import 'package:flutter/material.dart';
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
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final fetched = await ProductService.fetchProducts(); // Puedes incluir filtros aquí
    setState(() {
      _products = fetched;
      _isLoading = false;
    });
  }

  void _sort<T>(Comparable<T> Function(Product p) getField, int columnIndex, bool ascending) {
    _products.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
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

  void _navigateToCreateSale() {
    print("Ir a crear venta");
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

  @override
  Widget build(BuildContext context) {
    final productDataSource = ProductDataSource(
      context: context,
      products: _products,
      onDelete: _deleteProduct,
      onEdit: _loadProducts,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'Crear venta',
            onPressed: _navigateToCreateSale,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar producto',
            onPressed: _navigateToAddProduct,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.white,
                  dividerColor: Colors.transparent,
                  dataTableTheme: DataTableThemeData(
                    headingRowColor: MaterialStateProperty.all(Colors.blue),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                        }
                         return Colors.white;
                      },
                    ),
                  ),
                ),
                child: PaginatedDataTable(
                  header: const Text('Lista de productos'),
                  columns: [
                    DataColumn(
                      label: const Text('Nombre'),
                      onSort: (i, asc) => _sort((p) => p.name, i, asc),
                    ),
                    const DataColumn(label: Text('Descripción')),
                    DataColumn(
                      label: const Text('Precio'),
                      numeric: true,
                      onSort: (i, asc) => _sort((p) => p.price, i, asc),
                    ),
                    DataColumn(
                      label: const Text('Stock'),
                      numeric: true,
                      onSort: (i, asc) => _sort((p) => p.stock, i, asc),
                    ),
                    const DataColumn(label: Text('Categoría')),
                    const DataColumn(label: Text('Opciones')),
                  ],
                  source: productDataSource,
                  rowsPerPage: _rowsPerPage,
                  onRowsPerPageChanged: (value) {
                    setState(() {
                      _rowsPerPage = value ?? _rowsPerPage;
                    });
                  },
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  showCheckboxColumn: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductDataSource extends DataTableSource {
  final BuildContext context;
  final List<Product> products;
  final Future<void> Function(String id) onDelete;
  final VoidCallback onEdit;

  ProductDataSource({
    required this.context,
    required this.products,
    required this.onDelete,
    required this.onEdit,
  });

    @override
  DataRow getRow(int index) {
    if (index >= products.length) return const DataRow(cells: []);
    final product = products[index];
    final isEven = index % 2 == 0;

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        return isEven
          ? const Color(0xFFFFFFFF) // blanco
          : const Color(0xFFF0F0F0); // plomo claro
      }),
      cells: [
        DataCell(Text(product.name)),
        DataCell(Text(product.description ?? 'N/A')),
        DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
        DataCell(Text(product.stock.toString())),
        DataCell(Text(product.category ?? 'N/A')),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: EditProductModal(product: product),
                      ),
                    ),
                  ).then((_) => onEdit());
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: Text('¿Eliminar el producto "${product.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await onDelete(product.id);
                          },
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }


  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => products.length;

  @override
  int get selectedRowCount => 0;
}
