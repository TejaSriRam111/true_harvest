import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/subscription_controller.dart';
import 'package:task_new/models/advanced_subscription_model.dart';
import 'package:task_new/models/product_model.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/screens/subscriptions/subscription_checkout_screen.dart';

class SubscriptionSetupScreen extends ConsumerStatefulWidget {
  final Product product;
  final String selectedUnit;
  final SubscriptionPlanTemplate selectedPlan;

  const SubscriptionSetupScreen({
    Key? key,
    required this.product,
    required this.selectedUnit,
    required this.selectedPlan,
  }) : super(key: key);

  @override
  ConsumerState<SubscriptionSetupScreen> createState() =>
      _SubscriptionSetupScreenState();
}

class _SubscriptionSetupScreenState
    extends ConsumerState<SubscriptionSetupScreen> {
  DeliveryPattern selectedPattern = DeliveryPattern.daily;
  DateTime startDate = DateTime.now().add(const Duration(days: 1));
  int defaultQuantity = 1;
  List<String> selectedWeeklyDays = [];
  List<CustomDeliveryDate> customDates = [];

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default pattern based on plan type
    switch (widget.selectedPlan.planType) {
      case PlanType.daily:
        selectedPattern = DeliveryPattern.daily;
        break;
      case PlanType.alternateDay:
        selectedPattern = DeliveryPattern.alternate;
        break;
      case PlanType.weekly:
        selectedPattern = DeliveryPattern.weekly;
        selectedWeeklyDays = ['Mon', 'Wed', 'Fri'];
        break;
      default:
        selectedPattern = DeliveryPattern.daily;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Setup Subscription'),
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
                  // Plan Summary
                  _buildPlanSummary(),
                  const SizedBox(height: 20),

                  // Delivery Pattern Selection
                  // _buildDeliveryPatternSection(),
                  // const SizedBox(height: 20),

                  // Start Date Selection
                  _buildStartDateSection(),
                  const SizedBox(height: 20),

                  // Quantity Selection
                  _buildQuantitySection(),
                  const SizedBox(height: 20),

                  // Weekly Days Selection (if weekly pattern)
                  if (selectedPattern == DeliveryPattern.weekly)
                    _buildWeeklyDaysSection(),

                  // Custom Dates (if custom pattern)
                  if (selectedPattern == DeliveryPattern.custom)
                    _buildCustomDatesSection(),

                  const SizedBox(height: 20),

                  // Delivery Address
                  _buildDeliveryAddressSection(),
                  const SizedBox(height: 20),

                  // Price Summary
                  _buildPriceSummary(),
                ],
              ),
            ),
          ),

          // Continue Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continueToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSummary() {
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
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.selectedUnit} • ${widget.selectedPlan.name}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer, color: AppColors.darkGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${widget.selectedPlan.discountPercentage.toStringAsFixed(0)}% discount on ${widget.selectedPlan.durationInDays} days plan',
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
    );
  }

  // Widget _buildDeliveryPatternSection() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Delivery Pattern',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         ...DeliveryPattern.values.map((pattern) {
  //           final isSelected = selectedPattern == pattern;
  //           return Container(
  //             margin: const EdgeInsets.only(bottom: 8),
  //             child: InkWell(
  //               onTap: () => setState(() => selectedPattern = pattern),
  //               borderRadius: BorderRadius.circular(8),
  //               child: Container(
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     color: isSelected ? AppColors.darkGreen : Colors.grey[300]!,
  //                   ),
  //                   borderRadius: BorderRadius.circular(8),
  //                   color: isSelected ? AppColors.darkGreen.withOpacity(0.1) : null,
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Radio<DeliveryPattern>(
  //                       value: pattern,
  //                       groupValue: selectedPattern,
  //                       onChanged: (value) => setState(() => selectedPattern = value!),
  //                       activeColor: AppColors.darkGreen,
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             _getPatternTitle(pattern),
  //                             style: const TextStyle(
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.w600,
  //                             ),
  //                           ),
  //                           Text(
  //                             _getPatternDescription(pattern),
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               color: Colors.grey[600],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         }),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStartDateSection() {
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
            'Start Date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectStartDate,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.darkGreen),
                  const SizedBox(width: 12),
                  Text(
                    '${startDate.day}/${startDate.month}/${startDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
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
            'Quantity per Delivery',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: defaultQuantity > 1
                    ? () => setState(() => defaultQuantity--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.darkGreen,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  defaultQuantity.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => defaultQuantity++),
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.darkGreen,
              ),
              const SizedBox(width: 12),
              Text(
                widget.selectedUnit,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDaysSection() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
            'Select Delivery Days',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weekDays.map((day) {
              final isSelected = selectedWeeklyDays.contains(day);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedWeeklyDays.remove(day);
                    } else {
                      selectedWeeklyDays.add(day);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.darkGreen : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    day,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDatesSection() {
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
                'Custom Delivery Dates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addCustomDate,
                icon: const Icon(Icons.add),
                label: const Text('Add Date'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (customDates.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text(
                  'No custom dates added yet.\nTap "Add Date" to create your schedule.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...customDates.map(
              (customDate) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.darkGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${customDate.date.day}/${customDate.date.month}/${customDate.date.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      '${customDate.quantity} ${widget.selectedUnit}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    IconButton(
                      onPressed: () => _removeCustomDate(customDate),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressSection() {
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
            'Delivery Address',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your complete delivery address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.darkGreen),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _instructionsController,
            decoration: InputDecoration(
              hintText: 'Delivery instructions (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.darkGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final totalPrice = _calculateTotalPrice();
    final originalPrice = _calculateOriginalPrice();
    final savings = originalPrice - totalPrice;

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
            'Price Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Original Price'),
              Text('₹${originalPrice.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discount (${widget.selectedPlan.discountPercentage.toStringAsFixed(0)}%)',
                style: TextStyle(color: Colors.green[700]),
              ),
              Text(
                '-₹${savings.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.green[700]),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPatternTitle(DeliveryPattern pattern) {
    switch (pattern) {
      case DeliveryPattern.daily:
        return 'Daily Delivery';
      case DeliveryPattern.alternate:
        return 'Alternate Day';
      case DeliveryPattern.weekly:
        return 'Weekly Schedule';
      case DeliveryPattern.monthly:
        return 'Monthly Delivery';
      case DeliveryPattern.custom:
        return 'Custom Schedule';
    }
  }

  String _getPatternDescription(DeliveryPattern pattern) {
    switch (pattern) {
      case DeliveryPattern.daily:
        return 'Delivery every day';
      case DeliveryPattern.alternate:
        return 'Delivery every 2 days';
      case DeliveryPattern.weekly:
        return 'Choose specific days of the week';
      case DeliveryPattern.monthly:
        return 'Once every month';
      case DeliveryPattern.custom:
        return 'Create your own delivery schedule';
    }
  }

  double _calculateTotalPrice() {
    final service = ref.read(advancedSubscriptionServiceProvider);
    final endDate = startDate.add(
      Duration(days: widget.selectedPlan.durationInDays),
    );

    return service.calculateSubscriptionPrice(
      product: widget.product,
      unit: widget.selectedUnit,
      planType: widget.selectedPlan.planType,
      deliveryPattern: selectedPattern,
      startDate: startDate,
      endDate: endDate,
      defaultQty: defaultQuantity,
      weeklyDays: selectedWeeklyDays,
      customDates: customDates,
    );
  }

  double _calculateOriginalPrice() {
    final totalPrice = _calculateTotalPrice();
    return totalPrice / (1 - widget.selectedPlan.discountPercentage / 100);
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != startDate) {
      setState(() => startDate = picked);
    }
  }

  void _addCustomDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: startDate.add(
        Duration(days: widget.selectedPlan.durationInDays),
      ),
    );

    if (pickedDate != null) {
      // Show quantity dialog
      final int? quantity = await _showQuantityDialog();
      if (quantity != null) {
        setState(() {
          customDates.add(
            CustomDeliveryDate(date: pickedDate, quantity: quantity),
          );
          customDates.sort((a, b) => a.date.compareTo(b.date));
        });
      }
    }
  }

  void _removeCustomDate(CustomDeliveryDate customDate) {
    setState(() {
      customDates.remove(customDate);
    });
  }

  Future<int?> _showQuantityDialog() async {
    int quantity = 1;
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Quantity'),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () => setState(() => quantity--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, quantity),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _continueToCheckout() {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPattern == DeliveryPattern.weekly &&
        selectedWeeklyDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one delivery day'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPattern == DeliveryPattern.custom && customDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one custom delivery date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionCheckoutScreen(
          product: widget.product,
          selectedUnit: widget.selectedUnit,
          selectedPlan: widget.selectedPlan,
          deliveryPattern: selectedPattern,
          startDate: startDate,
          defaultQuantity: defaultQuantity,
          weeklyDays: selectedWeeklyDays,
          customDates: customDates,
          deliveryAddress: _addressController.text.trim(),
          deliveryInstructions: _instructionsController.text.trim(),
        ),
      ),
    );
  }
}
