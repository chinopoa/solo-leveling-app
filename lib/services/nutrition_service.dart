import 'dart:convert';
import 'package:http/http.dart' as http;

/// Product data returned from Open Food Facts
class ProductData {
  final String barcode;
  final String productName;
  final String? brand;
  final String? imageUrl;
  final double servingSize; // grams
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  ProductData({
    required this.barcode,
    required this.productName,
    this.brand,
    this.imageUrl,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
  });

  factory ProductData.fromOpenFoodFacts(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) {
      throw Exception('Product not found');
    }

    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    // Get serving size - default to 100g if not specified
    double servingSize = 100.0;
    if (product['serving_quantity'] != null) {
      servingSize = _parseDouble(product['serving_quantity']);
    } else if (product['nutrition_data_per'] == 'serving' &&
        product['serving_size'] != null) {
      // Try to parse serving size from string like "30g"
      final servingSizeStr = product['serving_size'].toString();
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(servingSizeStr);
      if (match != null) {
        servingSize = double.tryParse(match.group(1)!) ?? 100.0;
      }
    }

    // Get nutrition values per 100g and convert to per serving
    final factor = servingSize / 100.0;

    return ProductData(
      barcode: json['code']?.toString() ?? '',
      productName: product['product_name']?.toString() ??
                   product['product_name_en']?.toString() ??
                   'Unknown Product',
      brand: product['brands']?.toString(),
      imageUrl: product['image_front_url']?.toString() ??
                product['image_url']?.toString(),
      servingSize: servingSize,
      calories: _parseDouble(nutriments['energy-kcal_100g']) * factor,
      protein: _parseDouble(nutriments['proteins_100g']) * factor,
      carbs: _parseDouble(nutriments['carbohydrates_100g']) * factor,
      fat: _parseDouble(nutriments['fat_100g']) * factor,
      fiber: _parseDouble(nutriments['fiber_100g']) * factor,
      sugar: _parseDouble(nutriments['sugars_100g']) * factor,
      sodium: _parseDouble(nutriments['sodium_100g']) * factor * 1000, // Convert to mg
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Service for fetching nutrition data from Open Food Facts
class NutritionService {
  static const String _baseUrl = 'https://world.openfoodfacts.net/api/v2';
  static const String _userAgent = 'SoloLevelingApp/1.0 (Flutter)';

  // Simple in-memory cache
  final Map<String, ProductData> _cache = {};

  /// Fetch product data by barcode
  /// Returns null if product not found
  Future<ProductData?> getProductByBarcode(String barcode) async {
    // Check cache first
    if (_cache.containsKey(barcode)) {
      return _cache[barcode];
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/product/$barcode'
        '?fields=code,product_name,product_name_en,brands,nutriments,'
        'serving_quantity,serving_size,nutrition_data_per,'
        'image_front_url,image_url',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': _userAgent,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Check if product was found
        if (data['status'] == 0 || data['product'] == null) {
          return null;
        }

        final product = ProductData.fromOpenFoodFacts(data);

        // Cache the result
        _cache[barcode] = product;

        return product;
      }

      return null;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  /// Search products by name
  Future<List<ProductData>> searchProducts(String query, {int limit = 10}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search'
        '?search_terms=${Uri.encodeComponent(query)}'
        '&fields=code,product_name,product_name_en,brands,nutriments,'
        'serving_quantity,serving_size,nutrition_data_per,'
        'image_front_url,image_url'
        '&page_size=$limit',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': _userAgent,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>? ?? [];

        return products.map((p) {
          try {
            return ProductData.fromOpenFoodFacts({
              'code': p['code'],
              'product': p,
            });
          } catch (e) {
            return null;
          }
        }).whereType<ProductData>().toList();
      }

      return [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }
}
