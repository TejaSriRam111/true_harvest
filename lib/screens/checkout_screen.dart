import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/cart_controller.dart';
import 'package:task_new/controllers/verification_controller.dart';
import 'package:task_new/screens/payment_success_screen.dart';
import 'package:task_new/services/razorpay_service.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/screens/verification_dialog.dart';
import 'package:task_new/widgets/custom_alert_dialogue.dart';
import 'package:task_new/widgets/discount_offer_card.dart';
import 'package:task_new/widgets/cart_summary_card.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String selectedDeliveryType = 'standard';
  String selectedPaymentMethod = 'cash_on_delivery';
  bool isProcessingOrder = false;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  RazorPayService? _razorPayService;

  @override
  void initState() {
    super.initState();
    // Set default values
    _addressController.text = "123 Dairy Lane, Fresh Valley, CA 94102";
    _nameController.text = "John Doe";
    _emailController.text = "customer@trueharvest.com";
    _phoneController.text = "9876543210";

    // Initialize Razorpay service
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorPayService = RazorPayService(
      onPaymentSuccess: () async {
        final cartController = ref.read(cartProvider.notifier);
        await cartController.clearCart();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(
                orderId: 'TH${DateTime.now().millisecondsSinceEpoch}',
                amount: _getTotalAmount(),
              ),
            ),
          );
        }
      },
      onPaymentFailed: () {
        if (mounted) {
          setState(() {
            isProcessingOrder = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment failed, please try again"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      onPaymentClose: () {
        if (mounted) {
          setState(() {
            isProcessingOrder = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = ref.watch(cartProvider);
    final verificationService = ref.watch(verificationServiceProvider);
    final subtotal = cartController.subtotal;
    final deliveryFee = _getDeliveryFee();

    // Calculate discount
    final discountAmount =
        verificationService.isEligibleForDiscount(
          cartController.items,
          subtotal + deliveryFee,
        )
        ? verificationService.calculateDiscount(subtotal + deliveryFee)
        : 0.0;

    final total = subtotal + deliveryFee - discountAmount;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discount Offer Card
                  DiscountOfferCard(
                    subtotal: subtotal,
                    deliveryFee: deliveryFee,
                  ),

                  // Delivery Address Section
                  _buildSectionCard(
                    title: 'Delivery Address',
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightBackground,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.darkGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Home',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _addressController.text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: _showAddressDialog,
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                    color: AppColors.darkGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Delivery Time Section
                  _buildSectionCard(
                    title: 'Delivery Time',
                    child: Column(
                      children: [
                        _buildDeliveryOption(
                          'standard',
                          'Standard Delivery',
                          '2-3 days',
                          2.99,
                          Icons.schedule,
                        ),
                        const SizedBox(height: 12),
                        _buildDeliveryOption(
                          'express',
                          'Express Delivery',
                          'Tomorrow',
                          5.99,
                          Icons.flash_on,
                          isSelected: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment Method Section
                  _buildSectionCard(
                    title: 'Payment Method',
                    child: Column(
                      children: [
                        _buildPaymentOption(
                          'razorpay',
                          'Online Payment',
                          'Pay with Razorpay (Cards, UPI, Wallets)',
                          Icons.payment,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentOption(
                          'cash_on_delivery',
                          'Cash on Delivery',
                          'Pay when you receive',
                          Icons.money,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Order Summary Section
                  CartSummaryCard(
                    subtotal: subtotal,
                    deliveryFee: deliveryFee,
                    total: total,
                  ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),

          // Bottom Checkout Button
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessingOrder ? null : _handlePlaceOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessingOrder
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            selectedPaymentMethod == 'razorpay'
                                ? 'Pay ₹${total.toStringAsFixed(2)}'
                                : 'Place Order',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDeliveryOption(
    String value,
    String title,
    String subtitle,
    double price,
    IconData icon, {
    bool isSelected = false,
  }) {
    final isCurrentSelected = selectedDeliveryType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDeliveryType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentSelected ? AppColors.darkGreen : Colors.grey[200]!,
            width: isCurrentSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentSelected
                    ? AppColors.darkGreen.withOpacity(0.1)
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isCurrentSelected
                    ? AppColors.darkGreen
                    : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCurrentSelected
                          ? AppColors.darkGreen
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              '₹${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrentSelected ? AppColors.darkGreen : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    String subtitle,
    IconData icon, {
    bool isSelected = false,
  }) {
    final isCurrentSelected = selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        debugPrint('Payment method selected: $value');
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentSelected ? AppColors.darkGreen : Colors.grey[200]!,
            width: isCurrentSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentSelected
                    ? AppColors.darkGreen.withOpacity(0.1)
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isCurrentSelected
                    ? AppColors.darkGreen
                    : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCurrentSelected
                          ? AppColors.darkGreen
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal
                ? Colors.black87
                : (isDiscount ? Colors.green[700] : Colors.grey[600]),
          ),
        ),
        Text(
          '₹${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal
                ? AppColors.darkGreen
                : (isDiscount ? Colors.green[700] : Colors.black87),
          ),
        ),
      ],
    );
  }

  double _getDeliveryFee() {
    switch (selectedDeliveryType) {
      case 'standard':
        return 2.99;
      case 'express':
        return 5.99;
      default:
        return 2.99;
    }
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instructionsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Delivery Instructions (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handlePlaceOrder() {
    debugPrint('Selected payment method: $selectedPaymentMethod');

    if (selectedPaymentMethod == 'razorpay') {
      debugPrint('Processing Razorpay payment...');
      _processRazorpayPayment();
    } else {
      debugPrint('Processing Cash on Delivery order...');
      _placeCashOnDeliveryOrder();
    }
  }

  void _processRazorpayPayment() {
    setState(() {
      isProcessingOrder = true;
    });

    final total = _getTotalAmount();
    debugPrint('Opening Razorpay with amount: ₹$total');

    _razorPayService?.openPayment(
      amount: total,
      customerName: _nameController.text.trim(),
      customerEmail: _emailController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      description: 'True Harvest - Fresh Organic Products',
    );
  }

  Future<void> _placeCashOnDeliveryOrder() async {
    setState(() {
      isProcessingOrder = true;
    });

    // Simulate order processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isProcessingOrder = false;
    });

    if (!mounted) return;

    // Clear cart
    ref.read(cartProvider.notifier).clearCart();

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomAlertDialog(
        title: "Order Placed Successfully!",
        message:
            "Your order has been placed successfully. You will receive a confirmation shortly.",
        confirmText: "Continue Shopping",
        onConfirm: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  double _getTotalAmount() {
    final cartController = ref.read(cartProvider);
    final verificationService = ref.read(verificationServiceProvider);
    final subtotal = cartController.subtotal;
    final deliveryFee = _getDeliveryFee();

    // Calculate discount
    final discountAmount =
        verificationService.isEligibleForDiscount(
          cartController.items,
          subtotal + deliveryFee,
        )
        ? verificationService.calculateDiscount(subtotal + deliveryFee)
        : 0.0;

    return subtotal + deliveryFee - discountAmount;
  }

  Widget _buildVerificationBanner(verificationService, double discountAmount) {
    if (verificationService.isVerified && discountAmount > 0) {
      // Show success banner for verified users with discount
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.verified_user,
                color: Colors.green[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎉 Animal Kart Discount Applied!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                  Text(
                    'You saved ₹${discountAmount.toStringAsFixed(2)} on this order',
                    style: TextStyle(fontSize: 14, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (!verificationService.isVerified) {
      // Show verification offer banner
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkGreen.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_offer,
                color: AppColors.darkGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animal Kart User? Get 10% OFF!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const Text(
                    'Verify your account for instant discount',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _showVerificationDialog(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Verify'),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => const VerificationDialog(),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _razorPayService?.dispose();
    super.dispose();
  }
}
