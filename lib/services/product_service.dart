import 'dart:convert';
import '../models/product.dart';
import '../models/pagination_result.dart'; // Tendrás que crear esta clase
import 'api_service.dart';

class ProductService {
  static Future<PaginationResult<Product>> fetchProducts({
    int page = 1,
    int limit = 10,
    String? name,
    String? category,
    String? supplier,
    double? minPrice,
    double? maxPrice,
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
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (category != null && category.isNotEmpty)
        queryParams['category'] = category;
      if (supplier != null && supplier.isNotEmpty)
        queryParams['supplier'] = supplier;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();

      final response = await ApiService.get(
        '/products',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List productsJson = data['products'];
        final products = productsJson.map((json) => Product.fromJson(json)).toList();
        
        return PaginationResult<Product>(
          products: products,
          totalProducts: data['totalProducts'],
          totalPages: data['totalPages'],
          currentPage: data['currentPage'],
          limit: data['limit'],
        );
      } else {
        throw Exception('Error fetching products');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Product> createProduct(Product product) async {
    try {
      final response = await ApiService.post(
        '/products',
        product.toJson(),
      );

      if (response.statusCode == 201) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error creating product');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Product> updateProduct(String id, Product product) async {
    try {
      final response = await ApiService.put(
        '/products/$id',
        product.toJson(),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error updating product');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteProduct(String id) async {
    try {
      final response = await ApiService.delete('/products/$id');

      if (response.statusCode != 200) {
        throw Exception('Error deleting product');
      }
    } catch (e) {
      rethrow;
    }
  }
}