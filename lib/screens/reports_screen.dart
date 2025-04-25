import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';
import '../models/report.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _fechaInicio = DateTime.now().subtract(const Duration(days: 7));
  DateTime _fechaFin = DateTime.now();
  int _currentChartIndex = 0; // 0: Barras, 1: Líneas, 2: Pastel

  Report? _currentReport;
  bool _isLoading = false;
  String? _error;

  // Datos calculados a partir del reporte
  List<double> _ventasPorDia = [];
  List<String> _diasPeriodo = [];
  List<String> _categorias = [];
  List<double> _ventasPorProducto = [];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Formatear fechas para la API
      final startDate = DateFormat('yyyy-MM-dd').format(_fechaInicio);
      final endDate = DateFormat('yyyy-MM-dd').format(_fechaFin);

      // Crear un nuevo reporte con las fechas seleccionadas
      final report = await ReportService.createReport(
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _currentReport = report;
        _processReportData(report);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el reporte: $e';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el reporte: $e')),
      );
    }
  }

  void _processReportData(Report report) {
    // Procesar datos para gráficos diarios
    _processDailyData(report);

    // Procesar datos por producto para el gráfico de pie
    _processProductData(report);
  }

  void _processDailyData(Report report) {
    // Reiniciar listas
    _ventasPorDia = [];
    _diasPeriodo = [];

    // Crear un mapa para acumular ventas por día
    final Map<String, double> ventasPorDiaMap = {};

    // Duración en días del período de reporte
    final int diasEnPeriodo =
        report.endDate.difference(report.startDate).inDays + 1;

    // Inicializar cada día con 0 ventas
    for (int i = 0; i < diasEnPeriodo; i++) {
      final dia = report.startDate.add(Duration(days: i));
      final diaFormateado = DateFormat('yyyy-MM-dd').format(dia);
      ventasPorDiaMap[diaFormateado] = 0;
    }

    // Si no hay suficientes datos, usar datos basados en el total
    if (report.productsSold.isEmpty) {
      // Distribuir el total de ventas entre los días del período
      final ventaPromedioPorDia = report.totalRevenue / diasEnPeriodo;

      // Días de la semana
      final List<double> factoresDias = [
        0.7,
        0.8,
        0.9,
        1.1,
        1.3,
        1.5,
        0.7
      ]; // Lun a Dom

      int currentDay = 0;
      for (String diaKey in ventasPorDiaMap.keys) {
        final fecha = DateTime.parse(diaKey);
        final diaSemana = fecha.weekday - 1; // 0 = Lunes, 6 = Domingo

        // Usar factores por día de la semana para simular patrones reales
        final factor = factoresDias[diaSemana];
        ventasPorDiaMap[diaKey] = ventaPromedioPorDia * factor;

        currentDay = (currentDay + 1) % 7;
      }
    } else {
      // TODO: En el futuro, cuando la API devuelva datos por día, procesar aquí
      // Por ahora, distribuimos el total entre los días con una variación

      double totalVentas = report.totalRevenue;
      final ventaPromedioPorDia = totalVentas / diasEnPeriodo;

      // Crear variación por día similar a un patrón real de ventas
      final List<double> factoresDias = [
        0.7,
        0.8,
        0.9,
        1.1,
        1.3,
        1.5,
        0.7
      ]; // Lun a Dom

      for (String diaKey in ventasPorDiaMap.keys) {
        final fecha = DateTime.parse(diaKey);
        final diaSemana = fecha.weekday - 1; // 0 = Lunes, 6 = Domingo

        // Usar factores por día de la semana
        final factor = factoresDias[diaSemana];
        ventasPorDiaMap[diaKey] = ventaPromedioPorDia * factor;
      }
    }

    // Convertir el mapa a listas ordenadas
    final sortedDias = ventasPorDiaMap.keys.toList()..sort();
    _diasPeriodo = sortedDias.map((dia) {
      final fecha = DateTime.parse(dia);
      return DateFormat('EEE').format(fecha).substring(0, 3);
    }).toList();

    _ventasPorDia = sortedDias.map((dia) => ventasPorDiaMap[dia]!).toList();
  }

  void _processProductData(Report report) {
    // Reiniciar listas
    _categorias = [];
    _ventasPorProducto = [];

    // Usar los datos reales de productos vendidos si están disponibles
    if (report.productsSold.isNotEmpty) {
      // Ordenar productos por total de ventas (de mayor a menor)
      final productosOrdenados = List<ProductSold>.from(report.productsSold)
        ..sort((a, b) => b.total.compareTo(a.total));

      // Tomar los primeros 5 productos (o menos si no hay suficientes)
      final topProductos = productosOrdenados.take(5).toList();

      // Extraer nombres y totales
      _categorias = topProductos.map((p) => p.productName).toList();
      _ventasPorProducto = topProductos.map((p) => p.total).toList();
    } else {
      // Usar datos de muestra si no hay productos vendidos
      _categorias = ['Sin ventas'];
      _ventasPorProducto = [0];
    }
  }

  Future<void> _selectFechaInicio(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaInicio) {
      setState(() => _fechaInicio = picked);
      _loadReport(); // Recargar datos con la nueva fecha
    }
  }

  Future<void> _selectFechaFin(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaFin) {
      setState(() => _fechaFin = picked);
      _loadReport(); // Recargar datos con la nueva fecha
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(_error!, style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selectores de fecha
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectFechaInicio(context),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Desde:'),
                                      Text(DateFormat('dd/MM/yyyy')
                                          .format(_fechaInicio)),
                                      const Icon(Icons.calendar_today,
                                          size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectFechaFin(context),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Hasta:'),
                                      Text(DateFormat('dd/MM/yyyy')
                                          .format(_fechaFin)),
                                      const Icon(Icons.calendar_today,
                                          size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Selector de tipo de gráfico
                        SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildChartTypeButton('Barras', 0),
                              _buildChartTypeButton('Líneas', 1),
                              _buildChartTypeButton('Pastel', 2),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Gráfico seleccionado
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentChartIndex == 0
                                    ? 'Ventas por día'
                                    : _currentChartIndex == 1
                                        ? 'Tendencia de ventas'
                                        : 'Ventas por producto',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 300,
                                child: _buildCurrentChart(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Resumen numérico
                        const Text(
                          'Resumen',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildSummaryCard(
                                'Ventas totales',
                                '\$${NumberFormat("#,##0.00").format(_currentReport?.totalRevenue ?? 0)}',
                                Colors.blue),
                            _buildSummaryCard(
                                'Órdenes',
                                '${_currentReport?.totalSales ?? 0}',
                                const Color.fromARGB(255, 0, 121, 4)),
                            _buildSummaryCard(
                                'Ticket promedio',
                                _currentReport != null &&
                                        _currentReport!.totalSales > 0
                                    ? '\$${NumberFormat("#,##0.00").format(_currentReport!.totalRevenue / _currentReport!.totalSales)}'
                                    : '\$0.00',
                                const Color.fromARGB(255, 124, 75, 0)),
                            _buildSummaryCard(
                                'Productos vendidos',
                                '${_currentReport?.productsSold.length ?? 0}',
                                Colors.purple),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildChartTypeButton(String label, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _currentChartIndex == index,
        onSelected: (selected) {
          setState(() => _currentChartIndex = index);
        },
      ),
    );
  }

  Widget _buildCurrentChart() {
    switch (_currentChartIndex) {
      case 0:
        return BarChart(_buildBarChartData());
      case 1:
        return LineChart(_buildLineChartData());
      case 2:
        return PieChart(_buildPieChartData());
      default:
        return BarChart(_buildBarChartData());
    }
  }

  BarChartData _buildBarChartData() {
    return BarChartData(
      barGroups: List.generate(_ventasPorDia.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: _ventasPorDia[index],
              color: _getColorForIndex(index),
              borderRadius: BorderRadius.circular(4),
              width: 20,
            ),
          ],
        );
      }),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx >= 0 && idx < _diasPeriodo.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_diasPeriodo[idx]),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString());
            },
          ),
        ),
      ),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),
    );
  }

  LineChartData _buildLineChartData() {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(_ventasPorDia.length, (index) {
            return FlSpot(index.toDouble(), _ventasPorDia[index]);
          }),
          isCurved: true,
          color: Colors.blue,
          barWidth: 4,
          dotData: FlDotData(show: true),
          belowBarData:
              BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx >= 0 && idx < _diasPeriodo.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_diasPeriodo[idx]),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString());
            },
          ),
        ),
      ),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: true),
    );
  }

  PieChartData _buildPieChartData() {
    double total = _ventasPorProducto.fold(0, (sum, item) => sum + item);

    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 60,
      sections: List.generate(_categorias.length, (index) {
        double percentage =
            total > 0 ? (_ventasPorProducto[index] / total * 100) : 0;
        return PieChartSectionData(
          color: _getColorForIndex(index),
          value: _ventasPorProducto[index],
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 75,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}
