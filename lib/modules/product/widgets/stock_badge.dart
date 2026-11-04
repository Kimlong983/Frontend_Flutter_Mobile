import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/product/product_model.dart';

class StockBadge extends StatelessWidget {
  final ProductModel product;
  final bool showQuantity;

  const StockBadge({super.key, required this.product, this.showQuantity = false});

  @override
  Widget build(BuildContext context) {
    final qty = product.stockQuantity.toInt();
    final (Color bg, Color fg, String text) = !product.isInStock
        ? (AppColors.dangerLight, AppColors.danger, "Out of Stock")
        : product.isLowStock
            ? (AppColors.warningLight, AppColors.warning, showQuantity ? "$qty left" : "Low Stock")
            : (AppColors.successLight, AppColors.success, showQuantity ? "$qty in stock" : "In Stock");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
