import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:izi_frontend/screens/reports_screen.dart';
import '../models/sale.dart';
import '../services/sales_service.dart';
import '../widgets/create_sale_modal.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  late AnimationController _animationController;

  List<Sale> _allSales = [];
  List<Sale> _displayedSales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
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

  Future<void> _loadSales() async {
    try {
      setState(() => _isLoading = true);
      final fetched = await SalesService.fetchSales();
      setState(() {
        _allSales = fetched;
        _applySort();
        _updateDisplayedSales();
        _isLoading = false;
      });
      // Reiniciar animaciones cuando se cargan nuevos datos
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      // Mostrar un mensaje de error al usuario por consola
      print('Error cargando ventas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AnimationConfiguration.synchronized(
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: Text('Error cargando ventas: $e'),
              ),
            ),
          ),
        ),
      );
    }
  }

  void _sort<T>(Comparable<T> Function(Sale s) getField, int columnIndex,
      bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _applySort();
      _updateDisplayedSales();
    });
  }

  void _applySort() {
    _allSales.sort((a, b) {
      final aValue = _getSortValue(a);
      final bValue = _getSortValue(b);
      return _sortAscending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }

  Comparable<dynamic> _getSortValue(Sale sale) {
    switch (_sortColumnIndex) {
      case 0:
        return sale.user;
      case 1:
        return sale.note;
      case 2:
        return sale.date;
      case 3:
        return sale.total;
      default:
        return sale.date;
    }
  }

  void _updateDisplayedSales() {
    final start = _currentPage * _rowsPerPage;
    final end = (_currentPage + 1) * _rowsPerPage;
    _displayedSales = _allSales.sublist(
      start,
      end > _allSales.length ? _allSales.length : end,
    );
  }

  void _navigateToCreateSale() {
    showDialog(
      context: context,
      builder: (context) => AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 400),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: CreateSaleModal(),
              ),
            ),
          ),
        ),
      ),
    ).then((_) => _loadSales());
  }

  void _navigateToReport(BuildContext context) {
    print("Navegando a reportes");
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: ReportsScreen(),
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
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
                  fontSize: 14),
            ),
            if (_sortColumnIndex == columnIndex)
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
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.white,
                  key: ValueKey<bool>(_sortAscending),
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
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        title: const Text('Ventas'), backgroundColor: Colors.blue.shade700,
        //color texto blanco
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
                duration: const Duration(milliseconds: 500),
                child: FadeInAnimation(
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Botones con animaciones
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
                                        onPressed: () =>
                                            _navigateToReport(context),
                                        icon: const Icon(
                                            Icons.assignment_outlined),
                                        label: const Text('Ver Reportes'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.orange.shade400,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 1,
                                      child: ElevatedButton.icon(
                                        onPressed: _navigateToCreateSale,
                                        icon: const Icon(Icons.add),
                                        label: const Text('Crear Venta'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.green.shade400,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Encabezado de tabla con animación
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
                                          child:
                                              _buildHeaderCell('Cliente', 0)),
                                      Expanded(
                                          flex: 3,
                                          child: _buildHeaderCell(
                                              'Observaciones', 1)),
                                      Expanded(
                                          flex: 2,
                                          child: _buildHeaderCell('Fecha', 2)),
                                      Expanded(
                                          flex: 1,
                                          child: _buildHeaderCell('Total', 3,
                                              numeric: true)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Lista de ventas con animaciones escalonadas
                          Expanded(
                            child: AnimationLimiter(
                              child: ListView.builder(
                                itemCount: _displayedSales.length,
                                itemBuilder: (context, index) {
                                  final sale = _displayedSales[index];
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 400),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.15),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2)),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: Text(sale.user),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: Text(sale.note.isEmpty
                                                      ? '-'
                                                      : sale.note),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: Text(
                                                    '${sale.date.day}/${sale.date.month}/${sale.date.year}',
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: Text(
                                                    '\$${sale.total.toStringAsFixed(2)}',
                                                    textAlign: TextAlign.end,
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

                          // Control de paginación con animación
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
                                        onPressed: _currentPage > 0
                                            ? () {
                                                setState(() {
                                                  _currentPage--;
                                                  _updateDisplayedSales();
                                                });
                                              }
                                            : null,
                                      ),
                                      Text(
                                          'Página ${_currentPage + 1} de ${(_allSales.length / _rowsPerPage).ceil()}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed:
                                            (_currentPage + 1) * _rowsPerPage <
                                                    _allSales.length
                                                ? () {
                                                    setState(() {
                                                      _currentPage++;
                                                      _updateDisplayedSales();
                                                    });
                                                  }
                                                : null,
                                      ),
                                      const SizedBox(width: 20),
                                      const Text('Filas por página:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 8),
                                      DropdownButton<int>(
                                        value: _rowsPerPage,
                                        items: const [
                                          DropdownMenuItem(
                                              value: 10, child: Text('10')),
                                          DropdownMenuItem(
                                              value: 20, child: Text('20')),
                                          DropdownMenuItem(
                                              value: 50, child: Text('50')),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _rowsPerPage = value!;
                                            _currentPage = 0;
                                            _updateDisplayedSales();
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
