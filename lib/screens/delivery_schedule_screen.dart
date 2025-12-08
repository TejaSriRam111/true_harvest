import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/subscription_controller.dart';
import 'package:task_new/models/subscription_model.dart';
import 'package:task_new/utils/app_colors.dart';

class DeliveryScheduleScreen extends ConsumerWidget {
  const DeliveryScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionController = ref.watch(subscriptionProvider);
    final deliverySchedules = subscriptionController.deliverySchedules;
    final upcomingDeliveries = subscriptionController.upcomingDeliveries;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: const Text(
          'Delivery Schedule',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Summary Card
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
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Upcoming',
                    upcomingDeliveries.length.toString(),
                    Icons.schedule,
                    AppColors.darkGreen,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildSummaryItem(
                    'Delivered',
                    deliverySchedules
                        .where((d) => d.isDelivered)
                        .length
                        .toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildSummaryItem(
                    'Missed',
                    deliverySchedules
                        .where((d) => d.isMissed)
                        .length
                        .toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Filter Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppColors.darkGreen,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.darkGreen,
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Delivered'),
                      Tab(text: 'All'),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: TabBarView(
                      children: [
                        _buildDeliveryList(upcomingDeliveries, ref),
                        _buildDeliveryList(
                          deliverySchedules
                              .where((d) => d.isDelivered)
                              .toList(),
                          ref,
                        ),
                        _buildDeliveryList(deliverySchedules, ref),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDeliveryList(List<DeliverySchedule> deliveries, WidgetRef ref) {
    if (deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No deliveries found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        return _buildDeliveryCard(delivery, ref);
      },
    );
  }

  Widget _buildDeliveryCard(DeliverySchedule delivery, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        _formatDate(delivery.deliveryDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(delivery.deliveryDate),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(delivery.status),
              ],
            ),

            const SizedBox(height: 12),

            // Items
            const Text(
              'Items:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            ...delivery.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.darkGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.product.name} (${item.quantity}x ${item.unit})',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            if (delivery.deliveryNotes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        delivery.deliveryNotes!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions for upcoming deliveries
            if (delivery.isScheduled &&
                delivery.deliveryDate.isAfter(DateTime.now())) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rescheduleDelivery(delivery),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkGreen),
                      ),
                      icon: const Icon(Icons.schedule, size: 16),
                      label: const Text(
                        'Reschedule',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _skipDelivery(delivery),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                      ),
                      icon: const Icon(Icons.skip_next, size: 16),
                      label: const Text('Skip', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'scheduled':
        color = Colors.blue;
        text = 'Scheduled';
        icon = Icons.schedule;
        break;
      case 'delivered':
        color = Colors.green;
        text = 'Delivered';
        icon = Icons.check_circle;
        break;
      case 'missed':
        color = Colors.red;
        text = 'Missed';
        icon = Icons.cancel;
        break;
      case 'cancelled':
        color = Colors.grey;
        text = 'Cancelled';
        icon = Icons.block;
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final deliveryDay = DateTime(date.year, date.month, date.day);

    if (deliveryDay == today) {
      return 'Today';
    } else if (deliveryDay == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _rescheduleDelivery(DeliverySchedule delivery) {
    // TODO: Implement reschedule functionality
  }

  void _skipDelivery(DeliverySchedule delivery) {
    // TODO: Implement skip functionality
  }
}
