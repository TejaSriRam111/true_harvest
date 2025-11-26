// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:task_new/controllers/cart_controller.dart';
import 'package:task_new/controllers/verification_controller.dart';
import 'package:task_new/models/product_model.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/utils/svg_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_new/widgets/custom_alert_dialogue.dart';
import 'package:task_new/widgets/discount_offer_card.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late final cartController = ref.read(cartProvider);
  @override
  Widget build(BuildContext context) {
    final cartViewController = ref.watch(cartProvider);
    final cartItems = cartViewController.items;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        toolbarHeight: 80,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add some items to get started'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to home screen
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length + 1, // +1 for discount offer card
                    itemBuilder: (context, index) {
                      // Show discount offer card as first item
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DiscountOfferCard(
                            subtotal: cartViewController.subtotal,
                            deliveryFee: 2.99, // Default delivery fee
                          ),
                        );
                      }
                      
                      // Adjust index for cart items
                      final cartIndex = index - 1;
                      final item = cartItems[cartIndex];
                      final product = item.product;
                      final unit = item.selectedUnit;
                      final price = product.units
                          .firstWhere((u) => u.unitName == unit)
                          .price;

                      return Card(
                        color: AppColors.white,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  product.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      unit,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '₹${price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.darkGreen,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  cartController.updateQuantity(
                                                    product,
                                                    unit,
                                                    item.quantity - 1,
                                                  );
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                child: Text(
                                                  item.quantity.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  cartController.updateQuantity(
                                                    product,
                                                    unit,
                                                    item.quantity + 1,
                                                  );
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              GestureDetector(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (ctx) => CustomAlertDialog(
                                    title: "Remove From Cart",
                                    message:
                                        "Are you sure you want to remove from Cart ?",
                                    cancelText: "Cancel",
                                    confirmText: "Remove",
                                    confirmColor: AppColors.error,
                                    onConfirm: () {
                                      cartController.removeFromCart(
                                        product.id,
                                        unit,
                                      );
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ),
                                child: SvgPicture.string(
                                  SvgUtils.deleteIcon,
                                  color: AppColors.red,
                                  height: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Subtotal
                      _buildPriceRow('Subtotal', cartViewController.subtotal),
                      const SizedBox(height: 8),

                      // Delivery Fee
                      _buildPriceRow(
                        'Delivery Fee',
                        _calculateDeliveryFee(cartViewController.subtotal),
                      ),

                      // Divider
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, thickness: 1),
                      ),

                      // Total
                      _buildPriceRow(
                        'Total',
                        cartViewController.subtotal +
                            _calculateDeliveryFee(cartViewController.subtotal),
                        isTotal: true,
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/checkout');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightBackground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  double _calculateDeliveryFee(double subtotal) {
    // Free delivery for orders above 500
    return subtotal >= 500 ? 0 : 50; // 50 is the delivery fee
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.darkGreen : null,
          ),
        ),
      ],
    );
  }
}
