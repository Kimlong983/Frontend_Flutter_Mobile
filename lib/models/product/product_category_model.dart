/// ProductCategory schema.
class ProductCategoryModel {
  final int? id;
  final String? name;

  ProductCategoryModel({this.id, this.name});

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
    );
  }
}
