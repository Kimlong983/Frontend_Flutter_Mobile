import 'product_category_model.dart';

/// Product schema returned by GET /api/products.
class ProductModel {
  final int? id;
  final String? name;
  final String? productCode;
  final ProductCategoryModel? category;
  final double price;
  final double stockQuantity;
  final String? description;
  final String? imageUrl;
  final String? status;

  ProductModel({
    this.id,
    this.name,
    this.productCode,
    this.category,
    this.price = 0,
    this.stockQuantity = 0,
    this.description,
    this.imageUrl,
    this.status,
  });

  String get formattedPrice => "\$${price.toStringAsFixed(2)}";
  String get categoryName => category?.name ?? "General";
  bool get isInStock => stockQuantity > 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 10;
  bool get hasImage => imageUrl != null && imageUrl!.startsWith('http');

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
      productCode: json['productCode']?.toString(),
      category: json['category'] is Map
          ? ProductCategoryModel.fromJson(Map<String, dynamic>.from(json['category']))
          : null,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      status: json['status']?.toString(),
    );
  }
}
