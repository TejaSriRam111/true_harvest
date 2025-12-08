import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/subscription_controller.dart';
import 'package:task_new/models/advanced_subscription_model.dart';
import 'package:task_new/utils/app_colors.dart';

class SubscriptionDetailsScreen extends ConsumerStatefulWidget {
  final String subscriptionId;

  const SubscriptionDetailsScreen({
    Key? key,
    required this.subscriptionId,
  }) : super(key: key);

  @override
  ConsumerState<SubscriptionDetailsScreen> createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends ConsumerState<SubscriptionDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final subscriptionService = ref.watch(advancedSubscriptionServiceProvider);
    final subscription = subscriptionService.getSubscriptionById(widget.subscriptionId);

    if (subscription == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Subscription Details'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        body: const Center(
          child: Text('Subscription not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Subscription Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, subscription),
            itemBuilder: (context) => [
              if (subscription.isActive) ...[
                const PopupMenuItem(
                  value: 'pause',
                  child: Row(
                    children: [
                      Icon(Icons.pause_circle_outline),
                      SizedBox(width: 8),
                      Text('Pause Subscription'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'modify',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('Modify Quantity'),
                    ],
                  ),
                ),
              ],
              if (subscription.isPaused)
                const PopupMenuItem(
                  value: 'resume',
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_outline),
                      SizedBox(width: 8),
                      Text('Resume Subscription'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.red),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Header
            _buildSubscriptionHeader(subscription),
            const SizedBox(height: 20),

            // Status and Progress
            _buildStatusCard(subscription),
            const SizedBox(height: 20),

            // Delivery Schedule
            _buildDeliverySchedule(subscription),
            const SizedBox(height: 20),

            // Subscription Details
            _buildSubscriptionDetails(subscription),
            const SizedBox(height: 20),

            // Recent Deliveries
            _buildRecentDeliveries(subscription),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionHeader(AdvancedSubscription subscription) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.subscriptions,
                  color: AppColors.darkGreen,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.productName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${subscription.unit} • ${subscription.planType.toString().split('.').last.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(subscription.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        subscription.status.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(subscription.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Amount',
                  '₹${subscription.totalAmount.toStringAsFixed(2)}',
                  Icons.currency_rupee,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Remaining',
                  '${subscription.remainingDeliveries} deliveries',
                  Icons.local_shipping,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.darkGreen, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AdvancedSubscription subscription) {
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
            'Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Progress Bar
          LinearProgressIndicator(
            value: subscription.completionPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${subscription.completionPercentage.toStringAsFixed(1)}% Complete',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '${subscription.daysRemaining} days left',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Next Delivery Info
          if (subscription.nextDeliveryDate != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: AppColors.darkGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Next delivery: ${subscription.nextDeliveryDate!.day}/${subscription.nextDeliveryDate!.month}/${subscription.nextDeliveryDate!.year}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
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

  Widget _buildDeliverySchedule(AdvancedSubscription subscription) {
    final upcomingDeliveries = subscription.generateDeliverySchedule(
      DateTime.now(),
      DateTime.now().add(const Duration(days: 14)),
    ).take(5).toList();

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
            'Upcoming Deliveries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (upcomingDeliveries.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No upcoming deliveries scheduled',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...upcomingDeliveries.map((delivery) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.darkGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${delivery.date.day}/${delivery.date.month}/${delivery.date.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${delivery.quantity} ${delivery.unit}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails(AdvancedSubscription subscription) {
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
            'Subscription Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Subscription ID', '#${widget.subscriptionId.substring(widget.subscriptionId.length - 8).toUpperCase()}'),
          _buildDetailRow('Start Date', '${subscription.startDate.day}/${subscription.startDate.month}/${subscription.startDate.year}'),
          _buildDetailRow('End Date', '${subscription.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}'),
          _buildDetailRow('Delivery Pattern', _getDeliveryPatternText(subscription.deliveryPattern)),
          _buildDetailRow('Quantity per Delivery', '${subscription.defaultQty} ${subscription.unit}'),
          _buildDetailRow('Payment Mode', subscription.paymentMode.toString().split('.').last.toUpperCase()),
          if (subscription.weeklyDays.isNotEmpty)
            _buildDetailRow('Delivery Days', subscription.weeklyDays.join(', ')),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.darkGreen, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subscription.deliveryAddress,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          if (subscription.deliveryInstructions?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, color: AppColors.darkGreen, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subscription.deliveryInstructions!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDeliveries(AdvancedSubscription subscription) {
    final subscriptionService = ref.watch(advancedSubscriptionServiceProvider);
    final recentDeliveries = subscriptionService.deliverySchedule
        .where((delivery) => 
            delivery.subscriptionId == subscription.subscriptionId &&
            delivery.isDelivered)
        .take(5)
        .toList();

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
            'Recent Deliveries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (recentDeliveries.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No deliveries completed yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...recentDeliveries.map((delivery) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${delivery.date.day}/${delivery.date.month}/${delivery.date.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${delivery.quantity} ${delivery.unit} delivered',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (delivery.deliveredAt != null)
                    Text(
                      'Delivered',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.paused:
        return Colors.orange;
      case SubscriptionStatus.completed:
        return Colors.blue;
      case SubscriptionStatus.cancelled:
        return Colors.red;
    }
  }

  String _getDeliveryPatternText(DeliveryPattern pattern) {
    switch (pattern) {
      case DeliveryPattern.daily:
        return 'Daily';
      case DeliveryPattern.alternate:
        return 'Alternate Days';
      case DeliveryPattern.weekly:
        return 'Weekly';
      case DeliveryPattern.monthly:
        return 'Monthly';
      case DeliveryPattern.custom:
        return 'Custom Schedule';
    }
  }

  void _handleMenuAction(String action, AdvancedSubscription subscription) {
    switch (action) {
      case 'pause':
        _showPauseDialog(subscription);
        break;
      case 'resume':
        _resumeSubscription(subscription);
        break;
      case 'modify':
        _showModifyQuantityDialog(subscription);
        break;
      case 'cancel':
        _showCancelDialog(subscription);
        break;
    }
  }

  void _showPauseDialog(AdvancedSubscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pause Subscription'),
        content: const Text('Are you sure you want to pause this subscription? You can resume it anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _pauseSubscription(subscription);
            },
            child: const Text('Pause'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(AdvancedSubscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel this subscription? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelSubscription(subscription);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  void _showModifyQuantityDialog(AdvancedSubscription subscription) {
    int newQuantity = subscription.defaultQty;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modify Quantity'),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: newQuantity > 1 ? () => setState(() => newQuantity--) : null,
                icon: const Icon(Icons.remove),
              ),
              Text(
                newQuantity.toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => setState(() => newQuantity++),
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
            onPressed: () async {
              Navigator.pop(context);
              await _updateQuantity(subscription, newQuantity);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _pauseSubscription(AdvancedSubscription subscription) async {
    try {
      final service = ref.read(advancedSubscriptionServiceProvider);
      await service.pauseSubscription(subscription.subscriptionId, []);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription paused successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pause subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resumeSubscription(AdvancedSubscription subscription) async {
    try {
      final service = ref.read(advancedSubscriptionServiceProvider);
      await service.resumeSubscription(subscription.subscriptionId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription resumed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resume subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateQuantity(AdvancedSubscription subscription, int newQuantity) async {
    try {
      final service = ref.read(advancedSubscriptionServiceProvider);
      await service.updateSubscriptionQuantity(subscription.subscriptionId, newQuantity);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quantity updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelSubscription(AdvancedSubscription subscription) async {
    try {
      final service = ref.read(advancedSubscriptionServiceProvider);
      await service.cancelSubscription(subscription.subscriptionId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
