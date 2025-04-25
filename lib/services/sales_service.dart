import 'dart:convert';
import 'package:izi_frontend/models/pagination_result.dart';

import '../models/sale.dart';
import '../models/sale_item.dart';
import 'api_service.dart';

class SalesService {
  static Future<PaginationResult<Sale>> fetchSales({
    int page = 1,
    int limit = 10,
    String? user,
    double? minTotal,
    double? maxTotal,
    String? startDate,
    String? endDate,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      // Crear un mapa con los parámetros de la consulta
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      // Añadir los filtros si se proporcionan
      if (user != null && user.isNotEmpty) queryParams['user'] = user;
      if (minTotal != null) queryParams['minTotal'] = minTotal.toString();
      if (maxTotal != null) queryParams['maxTotal'] = maxTotal.toString();
      if (startDate != null && startDate.isNotEmpty)
        queryParams['startDate'] = startDate;
      if (endDate != null && endDate.isNotEmpty)
        queryParams['endDate'] = endDate;

      final response = await ApiService.get('/sales', queryParams: queryParams);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verificar que 'sales' exista y sea una lista
        if (data != null && data['sales'] is List) {
          final List salesJson = data['sales'];
          final sales = salesJson.map((json) => Sale.fromJson(json)).toList();

          return PaginationResult<Sale>(
            products: sales,
            totalProducts: data[
                'totalSales'], // Suponiendo que se llamen igual en la respuesta
            totalPages: data['totalPages'],
            currentPage: data['currentPage'],
            limit: data['limit'],
          );
        } else {
          throw Exception('No se encontraron ventas o formato inválido');
        }
      } else {
        throw Exception('Error al obtener ventas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error cargando ventas: $e');
      rethrow;
    }
  }

  static Future<Sale?> createSale({
    required List<SaleItem> items,
    String? note,
    String? user,
  }) async {
    try {
      final response = await ApiService.post('/sales', {
        'items': items.map((item) => item.toJson()).toList(),
        'note': note ?? '',
        'user': user ?? 'system',
      });

      if (response.statusCode == 201) {
        return null;
      } else {
        throw Exception('Error creating sale');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Sale> getSaleById(String id) async {
    try {
      final response = await ApiService.get('/sales/$id');

      if (response.statusCode == 200) {
        return Sale.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Sale not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Sale> updateSale(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await ApiService.put('/sales/$id', updates);

      if (response.statusCode == 200) {
        return Sale.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error updating sale');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteSale(String id) async {
    try {
      final response = await ApiService.delete('/sales/$id');

      if (response.statusCode != 200) {
        throw Exception('Error deleting sale');
      }
    } catch (e) {
      rethrow;
    }
  }
}
