import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/product/product_model.dart';

/// Product thumbnail from imageUrl, falling back to an icon.
class ProductImage extends StatelessWidget {
  final ProductModel product;
  final double size;

  const ProductImage({super.key, required this.product, required this.size});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: AppColors.primaryLight,
      child: Icon(Icons.inventory_rounded, color: AppColors.primary, size: size * 0.5),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: product.hasImage
          ? Image.network(
              product.imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            )
          : placeholder,
    );
  }
}
