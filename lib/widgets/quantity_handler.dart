// lib/widgets/quantity_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/cart_controller.dart';
import 'package:task_new/models/cart_item.dart';
import 'package:task_new/models/product_model.dart';

class QuantityHandler extends ConsumerWidget {
  final Product product;
  final String unit;
  final int initialQuantity;
  final Function(int) onQuantityChanged;

  const QuantityHandler({
    Key? key,
    required this.product,
    required this.unit,
    required this.initialQuantity,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final cartController = ref.watch(cartProvider);
        final cartItem = cartController.items.firstWhere(
          (item) => item.product.id == product.id && item.selectedUnit == unit,
          orElse: () => CartItem(
            product: product,
            selectedUnit: unit,
            quantity: initialQuantity,
          ),
        );

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease button
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  final newQuantity = cartItem.quantity > 1
                      ? cartItem.quantity - 1
                      : 1;
                  onQuantityChanged(newQuantity);
                },
              ),

              // Quantity display
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '${cartItem.quantity}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Increase button
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  onQuantityChanged(cartItem.quantity + 1);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
