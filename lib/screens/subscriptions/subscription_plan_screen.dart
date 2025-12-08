import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/subscription_controller.dart';
import 'package:task_new/models/advanced_subscription_model.dart';
import 'package:task_new/models/product_model.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/screens/subscriptions/subscription_setup_screen.dart';

class SubscriptionPlanScreen extends ConsumerStatefulWidget {
  final Product product;
  final String selectedUnit;

  const SubscriptionPlanScreen({
    Key? key,
    required this.product,
    required this.selectedUnit,
  }) : super(key: key);

  @override
  ConsumerState<SubscriptionPlanScreen> createState() =>
      _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState
    extends ConsumerState<SubscriptionPlanScreen> {
  SubscriptionPlanTemplate? selectedPlan;

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(subscriptionPlansProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Choose Subscription Plan'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Product Info Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
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
                        widget.selectedUnit,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        '₹${_getUnitPrice().toStringAsFixed(2)} per unit',
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
          ),

          // Plans List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final isSelected = selectedPlan == plan;
                final estimatedPrice = _calculateEstimatedPrice(plan);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.darkGreen
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => setState(() => selectedPlan = plan),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Plan Header
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          plan.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (plan.planType ==
                                            PlanType.quarterly) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'POPULAR',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      plan.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Radio<SubscriptionPlanTemplate>(
                                value: plan,
                                groupValue: selectedPlan,
                                onChanged: (value) =>
                                    setState(() => selectedPlan = value),
                                activeColor: AppColors.darkGreen,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Pricing
                          Row(
                            children: [
                              Text(
                                '₹${estimatedPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (plan.discountPercentage > 0) ...[
                                Text(
                                  '₹${(estimatedPrice / (1 - plan.discountPercentage / 100)).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${plan.discountPercentage.toStringAsFixed(0)}% OFF',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'For ${plan.durationInDays} days',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Features
                          ...plan.features
                              .take(3)
                              .map(
                                (feature) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: AppColors.darkGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                          if (plan.features.length > 3) ...[
                            const SizedBox(height: 4),
                            Text(
                              '+${plan.features.length - 3} more benefits',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Continue Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedPlan != null ? _continueToSetup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  selectedPlan != null
                      ? 'Continue with ${selectedPlan!.name}'
                      : 'Select a Plan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  double _calculateEstimatedPrice(SubscriptionPlanTemplate plan) {
    final unitPrice = _getUnitPrice();
    final daysInPlan = plan.durationInDays;

    // Estimate deliveries based on plan type
    int estimatedDeliveries;
    switch (plan.planType) {
      case PlanType.daily:
        estimatedDeliveries = daysInPlan;
        break;
      case PlanType.alternateDay:
        estimatedDeliveries = (daysInPlan / 2).ceil();
        break;
      case PlanType.weekly:
        estimatedDeliveries =
            (daysInPlan / 7).ceil() * 3; // Assume 3 days per week
        break;
      case PlanType.monthly:
      case PlanType.quarterly:
      case PlanType.halfYearly:
      case PlanType.annual:
        estimatedDeliveries = daysInPlan; // Daily delivery
        break;
      default:
        estimatedDeliveries = daysInPlan;
    }

    final originalPrice = estimatedDeliveries * unitPrice;
    final discountAmount = originalPrice * (plan.discountPercentage / 100);

    return originalPrice - discountAmount;
  }

  void _continueToSetup() {
    if (selectedPlan == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionSetupScreen(
          product: widget.product,
          selectedUnit: widget.selectedUnit,
          selectedPlan: selectedPlan!,
        ),
      ),
    );
  }
}
