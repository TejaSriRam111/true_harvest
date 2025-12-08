import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/subscription_controller.dart';
import 'package:task_new/models/advanced_subscription_model.dart';
import 'package:task_new/models/product_model.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/screens/subscription_success_screen.dart';

class SubscriptionCheckoutScreen extends ConsumerStatefulWidget {
  final Product product;
  final String selectedUnit;
  final SubscriptionPlanTemplate selectedPlan;
  final DeliveryPattern deliveryPattern;
  final DateTime startDate;
  final int defaultQuantity;
  final List<String> weeklyDays;
  final List<CustomDeliveryDate> customDates;
  final String deliveryAddress;
  final String deliveryInstructions;

  const SubscriptionCheckoutScreen({
    Key? key,
    required this.product,
    required this.selectedUnit,
    required this.selectedPlan,
    required this.deliveryPattern,
    required this.startDate,
    required this.defaultQuantity,
    required this.weeklyDays,
    required this.customDates,
    required this.deliveryAddress,
    required this.deliveryInstructions,
  }) : super(key: key);

  @override
  ConsumerState<SubscriptionCheckoutScreen> createState() =>
      _SubscriptionCheckoutScreenState();
}

class _SubscriptionCheckoutScreenState
    extends ConsumerState<SubscriptionCheckoutScreen> {
  PaymentMode selectedPaymentMode = PaymentMode.online;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();
    final originalPrice = _calculateOriginalPrice();
    final savings = originalPrice - totalPrice;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Subscription Checkout'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subscription Summary
                  _buildSubscriptionSummary(),
                  const SizedBox(height: 20),

                  // Delivery Schedule Preview
                  _buildDeliverySchedulePreview(),
                  const SizedBox(height: 20),

                  // Delivery Address
                  _buildDeliveryAddressCard(),
                  const SizedBox(height: 20),

                  // Payment Method Selection
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 20),

                  // Price Breakdown
                  _buildPriceBreakdown(totalPrice, originalPrice, savings),
                  const SizedBox(height: 20),

                  // Terms and Conditions
                  _buildTermsAndConditions(),
                ],
              ),
            ),
          ),

          // Checkout Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${totalPrice.toStringAsFixed(2)}',
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
                    onPressed: isProcessing ? null : _processSubscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            selectedPaymentMode == PaymentMode.online
                                ? 'Pay ₹${totalPrice.toStringAsFixed(2)}'
                                : 'Confirm Subscription',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

  Widget _buildSubscriptionSummary() {
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
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  widget.product.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.selectedUnit} • ${widget.selectedPlan.name}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      '${widget.defaultQuantity} ${widget.selectedUnit} per delivery',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  child: Text(
                    'You\'re saving ₹${(_calculateOriginalPrice() - _calculateTotalPrice()).toStringAsFixed(2)} with this subscription!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
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

  Widget _buildDeliverySchedulePreview() {
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
          const Text(
            'Delivery Schedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.darkGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                _getScheduleDescription(),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppColors.darkGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Starts: ${widget.startDate.day}/${widget.startDate.month}/${widget.startDate.year}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.event, color: AppColors.darkGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Duration: ${widget.selectedPlan.durationInDays} days',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (widget.deliveryPattern == DeliveryPattern.weekly &&
              widget.weeklyDays.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.today, color: AppColors.darkGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Days: ${widget.weeklyDays.join(', ')}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
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
          Row(
            children: [
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: AppColors.darkGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.deliveryAddress,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          if (widget.deliveryInstructions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, color: AppColors.darkGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.deliveryInstructions,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
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
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...PaymentMode.values.map((mode) {
            final isSelected = selectedPaymentMode == mode;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => selectedPaymentMode = mode),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppColors.darkGreen
                          : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? AppColors.darkGreen.withOpacity(0.1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Radio<PaymentMode>(
                        value: mode,
                        groupValue: selectedPaymentMode,
                        onChanged: (value) =>
                            setState(() => selectedPaymentMode = value!),
                        activeColor: AppColors.darkGreen,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getPaymentModeIcon(mode),
                        color: AppColors.darkGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPaymentModeTitle(mode),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _getPaymentModeDescription(mode),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(
    double totalPrice,
    double originalPrice,
    double savings,
  ) {
    final estimatedDeliveries = _calculateEstimatedDeliveries();
    final pricePerUnit = _getUnitPrice();

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
          const Text(
            'Price Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Unit Price',
            '₹${pricePerUnit.toStringAsFixed(2)} per ${widget.selectedUnit}',
          ),
          _buildPriceRow(
            'Estimated Deliveries',
            '$estimatedDeliveries deliveries',
          ),
          _buildPriceRow(
            'Quantity per Delivery',
            '${widget.defaultQuantity} ${widget.selectedUnit}',
          ),
          const Divider(),
          _buildPriceRow('Subtotal', '₹${originalPrice.toStringAsFixed(2)}'),
          _buildPriceRow(
            'Plan Discount (${widget.selectedPlan.discountPercentage.toStringAsFixed(0)}%)',
            '-₹${savings.toStringAsFixed(2)}',
            isDiscount: true,
          ),
          const Divider(),
          _buildPriceRow(
            'Total Amount',
            '₹${totalPrice.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount
                  ? Colors.green[700]
                  : (isTotal ? Colors.black87 : Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal
                  ? AppColors.darkGreen
                  : (isDiscount ? Colors.green[700] : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• You can pause/resume your subscription anytime\n'
            '• Minimum 24 hours notice required for changes\n'
            '• Refunds available for unused deliveries\n'
            '• Quality guarantee on all products',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getScheduleDescription() {
    switch (widget.deliveryPattern) {
      case DeliveryPattern.daily:
        return 'Daily delivery';
      case DeliveryPattern.alternate:
        return 'Every alternate day';
      case DeliveryPattern.weekly:
        return 'Weekly on selected days';
      case DeliveryPattern.monthly:
        return 'Monthly delivery';
      case DeliveryPattern.custom:
        return 'Custom schedule (${widget.customDates.length} deliveries)';
    }
  }

  IconData _getPaymentModeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.online:
        return Icons.credit_card;
      // case PaymentMode.cod:
      //   return Icons.money;
      case PaymentMode.wallet:
        return Icons.account_balance_wallet;
    }
  }

  String _getPaymentModeTitle(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.online:
        return 'Online Payment';
      // case PaymentMode.cod:
      //   return 'Cash on Delivery';
      case PaymentMode.wallet:
        return 'Wallet Payment';
    }
  }

  String _getPaymentModeDescription(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.online:
        return 'Pay securely with UPI, Card, or Net Banking';
      // case PaymentMode.cod:
      //   return 'Pay when you receive your first delivery';
      case PaymentMode.wallet:
        return 'Pay using your wallet balance';
    }
  }

  double _getUnitPrice() {
    try {
      return widget.product.units
          .firstWhere((unit) => unit.unitName == widget.selectedUnit)
          .price;
    } catch (e) {
      return 0.0;
    }
  }

  int _calculateEstimatedDeliveries() {
    switch (widget.deliveryPattern) {
      case DeliveryPattern.daily:
        return widget.selectedPlan.durationInDays;
      case DeliveryPattern.alternate:
        return (widget.selectedPlan.durationInDays / 2).ceil();
      case DeliveryPattern.weekly:
        final weeksInPlan = (widget.selectedPlan.durationInDays / 7).ceil();
        return weeksInPlan * widget.weeklyDays.length;
      case DeliveryPattern.monthly:
        return (widget.selectedPlan.durationInDays / 30).ceil();
      case DeliveryPattern.custom:
        return widget.customDates.length;
    }
  }

  double _calculateTotalPrice() {
    final service = ref.read(advancedSubscriptionServiceProvider);
    final endDate = widget.startDate.add(
      Duration(days: widget.selectedPlan.durationInDays),
    );

    return service.calculateSubscriptionPrice(
      product: widget.product,
      unit: widget.selectedUnit,
      planType: widget.selectedPlan.planType,
      deliveryPattern: widget.deliveryPattern,
      startDate: widget.startDate,
      endDate: endDate,
      defaultQty: widget.defaultQuantity,
      weeklyDays: widget.weeklyDays,
      customDates: widget.customDates,
    );
  }

  double _calculateOriginalPrice() {
    final totalPrice = _calculateTotalPrice();
    return totalPrice / (1 - widget.selectedPlan.discountPercentage / 100);
  }

  Future<void> _processSubscription() async {
    setState(() => isProcessing = true);

    try {
      final service = ref.read(advancedSubscriptionServiceProvider);

      // Create subscription
      final subscriptionId = await service.createSubscription(
        userId: 'current_user_id', // Replace with actual user ID
        product: widget.product,
        unit: widget.selectedUnit,
        planType: widget.selectedPlan.planType,
        deliveryPattern: widget.deliveryPattern,
        startDate: widget.startDate,
        defaultQty: widget.defaultQuantity,
        weeklyDays: widget.weeklyDays,
        customDates: widget.customDates,
        deliveryAddress: widget.deliveryAddress,
        deliveryInstructions: widget.deliveryInstructions.isNotEmpty
            ? widget.deliveryInstructions
            : null,
        paymentMode: selectedPaymentMode,
      );

      // Navigate to success screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SubscriptionSuccessScreen(subscriptionId: subscriptionId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }
}
