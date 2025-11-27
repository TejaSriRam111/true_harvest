import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/subscription_controller.dart';
import 'package:task_new/models/subscription_model.dart';
import 'package:task_new/routes/app_routes.dart';
import 'package:task_new/utils/app_colors.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionController = ref.watch(subscriptionProvider);
    final activeSubscriptions = subscriptionController.activeSubscriptions;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.darkGreen,
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Subscriptions',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.darkGreen, AppColors.primary],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.subscriptions,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),

          // Content
          if (activeSubscriptions.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == 0) {
                  return _buildQuickActions(context);
                }
                final subscription = activeSubscriptions[index - 1];
                return _buildSubscriptionCard(context, ref, subscription);
              }, childCount: activeSubscriptions.length + 1),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToPlans(context),
        backgroundColor: AppColors.darkGreen,
        icon: const Icon(Icons.add, color: AppColors.cream),
        label: const Text('New Plan', style: TextStyle(color: AppColors.cream)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subscriptions_outlined,
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Subscriptions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your journey to fresh, organic products delivered to your doorstep',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToPlans(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Browse Plans',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
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
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Browse Plans',
                  Icons.shopping_bag_outlined,
                  () => _navigateToPlans(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Custom Plan',
                  Icons.tune,
                  () => _navigateToCustomPlan(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Schedule',
                  Icons.schedule,
                  () => _showDeliverySchedule(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.darkGreen),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    WidgetRef ref,
    UserSubscription subscription,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.plan.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      Text(
                        subscription.plan.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(subscription.status),
              ],
            ),

            const SizedBox(height: 16),

            // Details
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Next Delivery',
                    subscription.nextDeliveryDate != null
                        ? _formatDate(subscription.nextDeliveryDate!)
                        : 'Not scheduled',
                    Icons.local_shipping,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Days Left',
                    '${subscription.daysRemaining} days',
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: subscription.isPaused
                        ? () => _resumeSubscription(ref, subscription.id)
                        : () => _pauseSubscription(ref, subscription.id),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: subscription.isPaused
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    icon: Icon(
                      subscription.isPaused ? Icons.play_arrow : Icons.pause,
                      size: 16,
                    ),
                    label: Text(
                      subscription.isPaused ? 'Resume' : 'Pause',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showSubscriptionDetails(context, subscription),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.darkGreen),
                    ),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text(
                      'Details',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelSubscription(ref, subscription.id),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.darkGreen),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToPlans(BuildContext context) {
    AppRoutes.navigateTo(context, '/subscription-plans');
  }

  void _navigateToCustomPlan(BuildContext context) {
    AppRoutes.navigateTo(context, '/custom-subscription');
  }

  void _showDeliverySchedule(BuildContext context) {
    AppRoutes.navigateTo(context, '/delivery-schedule');
  }

  void _showSubscriptionDetails(
    BuildContext context,
    UserSubscription subscription,
  ) {
    AppRoutes.navigateTo(
      context,
      '/subscription-details',
      arguments: subscription,
    );
  }

  Future<void> _pauseSubscription(WidgetRef ref, String subscriptionId) async {
    final controller = ref.read(subscriptionProvider);
    final success = await controller.pauseSubscription(subscriptionId);

    if (success) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(
          content: Text('Subscription paused successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resumeSubscription(WidgetRef ref, String subscriptionId) async {
    final controller = ref.read(subscriptionProvider);
    final success = await controller.resumeSubscription(subscriptionId);

    if (success) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(
          content: Text('Subscription resumed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _cancelSubscription(WidgetRef ref, String subscriptionId) async {
    final controller = ref.read(subscriptionProvider);
    final success = await controller.cancelSubscription(subscriptionId);

    if (success) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(
          content: Text('Subscription cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
