import 'dart:convert';
import '../models/product.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;

class ProductService {
  static Future<List<Product>> fetchProducts({int page = 1, int limit = 10}) async {
    try {
      final response = await ApiService.get(
        '/products',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List productsJson = data['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
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
