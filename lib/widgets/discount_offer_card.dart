import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/verification_controller.dart';
import 'package:task_new/controllers/cart_controller.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/utils/app_constants.dart';
import 'package:task_new/screens/verification_dialog.dart';

class DiscountOfferCard extends ConsumerWidget {
  final double subtotal;
  final double deliveryFee;

  const DiscountOfferCard({
    Key? key,
    required this.subtotal,
    required this.deliveryFee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationService = ref.watch(verificationServiceProvider);
    final cartController = ref.watch(cartProvider);
    final totalAmount = subtotal + deliveryFee;
    
    final discountAmount = ref.watch(discountAmountProvider(totalAmount));
    final isEligible = verificationService.isEligibleForDiscount(
      cartController.items, 
      totalAmount
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: verificationService.isVerified && isEligible
                      ? Colors.green[100]
                      : AppColors.darkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  verificationService.isVerified && isEligible
                      ? Icons.check_circle
                      : Icons.local_offer,
                  color: verificationService.isVerified && isEligible
                      ? Colors.green[700]
                      : AppColors.darkGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verificationService.isVerified && isEligible
                          ? '🎉 Animal Kart Discount Applied!'
                          : '🎯 Animal Kart Special Offer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: verificationService.isVerified && isEligible
                            ? Colors.green[800]
                            : AppColors.darkGreen,
                      ),
                    ),
                    Text(
                      verificationService.isVerified && isEligible
                          ? 'You saved ₹${discountAmount.toStringAsFixed(2)} on this order'
                          : 'Get 10% OFF on your order',
                      style: TextStyle(
                        fontSize: 14,
                        color: verificationService.isVerified && isEligible
                            ? Colors.green[700]
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (!verificationService.isVerified)
                TextButton(
                  onPressed: () => _showVerificationDialog(context),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Verify'),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Offer Details
          _buildOfferDetails(context, verificationService, cartController, totalAmount, isEligible),

          // Progress Indicators
          if (!verificationService.isVerified || !isEligible) ...[
            const SizedBox(height: 16),
            _buildProgressIndicators(context, verificationService, cartController, totalAmount),
          ],
        ],
      ),
    );
  }

  Widget _buildOfferDetails(
    BuildContext context,
    verificationService,
    cartController,
    double totalAmount,
    bool isEligible,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Offer Details:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildOfferCondition(
            '💰 Minimum Order',
            '₹${AppConstants.minimumOrderForDiscount.toStringAsFixed(0)}',
            totalAmount >= AppConstants.minimumOrderForDiscount,
            'Current: ₹${totalAmount.toStringAsFixed(2)}',
          ),
          _buildOfferCondition(
            '✅ Animal Kart User',
            'Verified Account',
            verificationService.isVerified,
            verificationService.isVerified ? 'Verified' : 'Not Verified',
          ),
          _buildOfferCondition(
            '🥛 Milk Requirement',
            '1+ Liter',
            _checkMilkRequirement(cartController.items),
            _getMilkStatus(cartController.items),
          ),
          _buildOfferCondition(
            '🍎 Fruit Requirement',
            'Any Fruit',
            _checkFruitRequirement(cartController.items),
            _getFruitStatus(cartController.items),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCondition(
    String title,
    String requirement,
    bool isMet,
    String status,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green[600] : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isMet ? Colors.green[700] : Colors.grey[600],
                    fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: isMet ? Colors.green[600] : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(
    BuildContext context,
    verificationService,
    cartController,
    double totalAmount,
  ) {
    final remainingAmount = AppConstants.minimumOrderForDiscount - totalAmount;
    final progressPercentage = (totalAmount / AppConstants.minimumOrderForDiscount).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (totalAmount < AppConstants.minimumOrderForDiscount) ...[
          const Text(
            'Add more items to unlock discount:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add ₹${remainingAmount.toStringAsFixed(2)} more to reach minimum order',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],

        if (!verificationService.isVerified) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.darkGreen, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Verify your Animal Kart account to unlock this discount',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool _checkMilkRequirement(List items) {
    double milkQuantity = 0;
    for (var item in items) {
      String productName = item.product.name.toLowerCase();
      if (productName.contains('milk')) {
        if (item.selectedUnit.toLowerCase().contains('liter') || 
            item.selectedUnit.toLowerCase().contains('l')) {
          milkQuantity += item.quantity;
        }
      }
    }
    return milkQuantity >= AppConstants.minimumMilkQuantity;
  }

  bool _checkFruitRequirement(List items) {
    for (var item in items) {
      String productName = item.product.name.toLowerCase();
      if (productName.contains('fruit') || 
          item.product.category.toLowerCase().contains('fruit')) {
        return true;
      }
    }
    return false;
  }

  String _getMilkStatus(List items) {
    double milkQuantity = 0;
    for (var item in items) {
      String productName = item.product.name.toLowerCase();
      if (productName.contains('milk')) {
        if (item.selectedUnit.toLowerCase().contains('liter') || 
            item.selectedUnit.toLowerCase().contains('l')) {
          milkQuantity += item.quantity;
        }
      }
    }
    return milkQuantity >= AppConstants.minimumMilkQuantity 
        ? '${milkQuantity.toStringAsFixed(1)}L Added' 
        : 'Add ${(AppConstants.minimumMilkQuantity - milkQuantity).toStringAsFixed(1)}L';
  }

  String _getFruitStatus(List items) {
    bool hasFruit = _checkFruitRequirement(items);
    return hasFruit ? 'Added' : 'Add Fruits';
  }

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const VerificationDialog(),
    );
  }
}
