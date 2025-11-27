import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/subscription_controller.dart';
import 'package:task_new/models/subscription_model.dart';
import 'package:task_new/routes/app_routes.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/widgets/custom_alert_dialogue.dart';

class SubscriptionDetailsScreen extends ConsumerWidget {
  final UserSubscription subscription;

  const SubscriptionDetailsScreen({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: const Text(
          'Subscription Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              if (subscription.isActive)
                const PopupMenuItem(
                  value: 'pause',
                  child: Row(
                    children: [
                      Icon(Icons.pause, size: 16),
                      SizedBox(width: 8),
                      Text('Pause Subscription'),
                    ],
                  ),
                ),
              if (subscription.isPaused)
                const PopupMenuItem(
                  value: 'resume',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow, size: 16),
                      SizedBox(width: 8),
                      Text('Resume Subscription'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'modify',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Modify Items'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cancel Subscription', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.plan.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            Text(
                              subscription.plan.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(subscription.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Total Amount',
                          '₹${subscription.totalAmount.toStringAsFixed(2)}',
                          Icons.currency_rupee,
                          AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Days Remaining',
                          '${subscription.daysRemaining} days',
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Subscription Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subscription Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...subscription.items.map((item) => _buildItemCard(item)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Delivery Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDeliveryInfo('Next Delivery', 
                    subscription.nextDeliveryDate != null 
                      ? _formatDate(subscription.nextDeliveryDate!)
                      : 'Not scheduled',
                    Icons.local_shipping),
                  const SizedBox(height: 12),
                  _buildDeliveryInfo('Delivery Address', 
                    subscription.deliveryAddress, Icons.location_on),
                  if (subscription.deliveryInstructions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDeliveryInfo('Special Instructions', 
                      subscription.deliveryInstructions, Icons.note),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Subscription Timeline
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subscription Timeline',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimelineItem('Started', subscription.startDate, true),
                  if (subscription.pausedAt != null)
                    _buildTimelineItem('Paused', subscription.pausedAt!, false),
                  if (subscription.cancelledAt != null)
                    _buildTimelineItem('Cancelled', subscription.cancelledAt!, false),
                  _buildTimelineItem('Ends', subscription.endDate, false),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (subscription.isActive || subscription.isPaused) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: subscription.isPaused
                            ? () => _resumeSubscription(context, ref)
                            : () => _pauseSubscription(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: subscription.isPaused ? Colors.green : Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          subscription.isPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white,
                        ),
                        label: Text(
                          subscription.isPaused ? 'Resume Subscription' : 'Pause Subscription',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _viewDeliverySchedule(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkGreen),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.schedule, color: AppColors.darkGreen),
                      label: const Text(
                        'View Delivery Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SubscriptionStatus status) {
    Color color;
    String text;

    switch (status) {
      case SubscriptionStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case SubscriptionStatus.paused:
        color = Colors.orange;
        text = 'Paused';
        break;
      case SubscriptionStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      case SubscriptionStatus.expired:
        color = Colors.grey;
        text = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(SubscriptionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${item.quantity}x ${item.unit} • ${_getFrequencyText(item.frequency)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.pricePerDelivery.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.darkGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String label, DateTime date, bool isFirst) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.darkGreen : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              if (label != 'Ends')
                Container(
                  width: 2,
                  height: 20,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getFrequencyText(DeliveryFrequency frequency) {
    switch (frequency) {
      case DeliveryFrequency.daily:
        return 'Daily';
      case DeliveryFrequency.everyOtherDay:
        return 'Every Other Day';
      case DeliveryFrequency.weekly:
        return 'Weekly';
      case DeliveryFrequency.biWeekly:
        return 'Bi-Weekly';
      case DeliveryFrequency.monthly:
        return 'Monthly';
    }
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'pause':
        _pauseSubscription(context, ref);
        break;
      case 'resume':
        _resumeSubscription(context, ref);
        break;
      case 'modify':
        _modifySubscription(context);
        break;
      case 'cancel':
        _showCancelDialog(context, ref);
        break;
    }
  }

  Future<void> _pauseSubscription(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(subscriptionProvider);
    final success = await controller.pauseSubscription(subscription.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription paused successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pause subscription'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resumeSubscription(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(subscriptionProvider);
    final success = await controller.resumeSubscription(subscription.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription resumed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resume subscription'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _modifySubscription(BuildContext context) {
    // Navigate to modification screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modification feature coming soon!')),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => CustomAlertDialog(
        title: "Cancel Subscription",
        message: "Are you sure you want to cancel this subscription? This action cannot be undone.",
        cancelText: "Keep Subscription",
        confirmText: "Cancel Subscription",
        confirmColor: Colors.red,
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final controller = ref.read(subscriptionProvider);
          final success = await controller.cancelSubscription(subscription.id);
          
          if (success) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscription cancelled successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to cancel subscription'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _viewDeliverySchedule(BuildContext context) {
    AppRoutes.navigateTo(context, '/delivery-schedule');
  }
}
