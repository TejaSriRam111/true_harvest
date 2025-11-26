import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/cart_controller.dart';
import 'package:task_new/controllers/verification_controller.dart';
import 'package:task_new/utils/app_colors.dart';

class CartSummaryCard extends ConsumerWidget {
  final double subtotal;
  final double deliveryFee;
  final double total;

  const CartSummaryCard({
    Key? key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartController = ref.watch(cartProvider);
    final verificationService = ref.watch(verificationServiceProvider);
    final totalBeforeDiscount = subtotal + deliveryFee;
    final discountAmount = ref.watch(discountAmountProvider(totalBeforeDiscount));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.darkGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Cart Items
          ...cartController.items.map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(item.product.imageUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${item.quantity}x ${item.selectedUnit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${(item.product.units.firstWhere((u) => u.unitName == item.selectedUnit).price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 24, thickness: 1),

          // Price Breakdown
          _buildPriceRow('Subtotal', subtotal),
          const SizedBox(height: 8),
          _buildPriceRow('Delivery Fee', deliveryFee),
          const SizedBox(height: 8),
          _buildPriceRow('Tax', 0.0),
          
          // Discount Row
          if (discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildDiscountRow(discountAmount),
          ],

          const Divider(height: 24, thickness: 1),

          // Total
          _buildTotalRow(total, discountAmount > 0),

          // Savings Summary
          if (discountAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.savings, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You\'re saving ₹${discountAmount.toStringAsFixed(2)}!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                        Text(
                          'Animal Kart discount applied',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '10% OFF',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountRow(double discountAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.local_offer, size: 16, color: Colors.green[700]),
            const SizedBox(width: 4),
            Text(
              'Animal Kart Discount (10%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        Text(
          '-₹${discountAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(double total, bool hasDiscount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hasDiscount ? 'Total (After Discount)' : 'Total',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          '₹${total.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: hasDiscount ? Colors.green[700] : AppColors.darkGreen,
          ),
        ),
      ],
    );
  }
}
