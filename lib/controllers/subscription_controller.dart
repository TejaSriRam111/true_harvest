import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_new/models/advanced_subscription_model.dart'
    hide SubscriptionStatus;
import 'package:task_new/models/subscription_model.dart';
import 'package:task_new/services/subscription_service.dart';

final subscriptionProvider = ChangeNotifierProvider<SubscriptionController>((
  ref,
) {
  return SubscriptionController();
});

// Advanced subscription service provider
final advancedSubscriptionServiceProvider =
    ChangeNotifierProvider<SubscriptionService>((ref) {
      return SubscriptionService();
    });

// Providers for specific subscription data
final activeSubscriptionsProvider = Provider<List<AdvancedSubscription>>((ref) {
  final service = ref.watch(advancedSubscriptionServiceProvider);
  return service.activeSubscriptions;
});

final todayDeliveriesProvider = Provider<List<DeliveryScheduleItem>>((ref) {
  final service = ref.watch(advancedSubscriptionServiceProvider);
  return service.todayDeliveries;
});

final subscriptionPlansProvider = Provider<List<SubscriptionPlanTemplate>>((
  ref,
) {
  return SubscriptionPlanTemplate.getDefaultPlans();
});

class SubscriptionController extends ChangeNotifier {
  List<SubscriptionPlan> _plans = [];
  List<UserSubscription> _userSubscriptions = [];
  List<DeliverySchedule> _deliverySchedules = [];
  bool _isLoading = false;

  // Getters
  List<SubscriptionPlan> get plans => List.unmodifiable(_plans);
  List<UserSubscription> get userSubscriptions =>
      List.unmodifiable(_userSubscriptions);
  List<DeliverySchedule> get deliverySchedules =>
      List.unmodifiable(_deliverySchedules);
  bool get isLoading => _isLoading;

  // Active subscriptions
  List<UserSubscription> get activeSubscriptions =>
      _userSubscriptions.where((sub) => sub.isActive).toList();

  // Upcoming deliveries
  List<DeliverySchedule> get upcomingDeliveries => _deliverySchedules
      .where(
        (delivery) =>
            delivery.isScheduled &&
            delivery.deliveryDate.isAfter(DateTime.now()),
      )
      .toList();

  SubscriptionController() {
    _initializeData();
  }

  void _initializeData() {
    _plans = _getInitialPlans();
    _userSubscriptions = [];
    _deliverySchedules = [];
    notifyListeners();
  }

  // Create a new subscription
  Future<bool> createSubscription({
    required SubscriptionPlan plan,
    required List<SubscriptionItem> items,
    required String deliveryAddress,
    String deliveryInstructions = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final subscription = UserSubscription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id', // Replace with actual user ID
        plan: plan,
        items: items,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: plan.durationInDays)),
        nextDeliveryDate: _calculateNextDeliveryDate(items),
        status: SubscriptionStatus.active,
        deliveryAddress: deliveryAddress,
        deliveryInstructions: deliveryInstructions,
        totalAmount: _calculateTotalAmount(plan, items),
        createdAt: DateTime.now(),
      );

      _userSubscriptions.add(subscription);
      _generateDeliverySchedule(subscription);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Pause subscription
  Future<bool> pauseSubscription(String subscriptionId) async {
    try {
      final index = _userSubscriptions.indexWhere(
        (sub) => sub.id == subscriptionId,
      );
      if (index != -1) {
        _userSubscriptions[index] = _userSubscriptions[index].copyWith(
          status: SubscriptionStatus.paused,
          pausedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Resume subscription
  Future<bool> resumeSubscription(String subscriptionId) async {
    try {
      final index = _userSubscriptions.indexWhere(
        (sub) => sub.id == subscriptionId,
      );
      if (index != -1) {
        _userSubscriptions[index] = _userSubscriptions[index].copyWith(
          status: SubscriptionStatus.active,
          pausedAt: null,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      final index = _userSubscriptions.indexWhere(
        (sub) => sub.id == subscriptionId,
      );
      if (index != -1) {
        _userSubscriptions[index] = _userSubscriptions[index].copyWith(
          status: SubscriptionStatus.cancelled,
          cancelledAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update subscription items
  Future<bool> updateSubscriptionItems(
    String subscriptionId,
    List<SubscriptionItem> newItems,
  ) async {
    try {
      final index = _userSubscriptions.indexWhere(
        (sub) => sub.id == subscriptionId,
      );
      if (index != -1) {
        final subscription = _userSubscriptions[index];
        _userSubscriptions[index] = subscription.copyWith(
          items: newItems,
          totalAmount: _calculateTotalAmount(subscription.plan, newItems),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  DateTime? _calculateNextDeliveryDate(List<SubscriptionItem> items) {
    if (items.isEmpty) return null;

    // Find the most frequent delivery frequency
    final frequencies = items.map((item) => item.frequency).toList();
    final mostFrequent = frequencies.first; // Simplified logic

    switch (mostFrequent) {
      case DeliveryFrequency.daily:
        return DateTime.now().add(const Duration(days: 1));
      case DeliveryFrequency.everyOtherDay:
        return DateTime.now().add(const Duration(days: 2));
      case DeliveryFrequency.weekly:
        return DateTime.now().add(const Duration(days: 7));
      case DeliveryFrequency.biWeekly:
        return DateTime.now().add(const Duration(days: 14));
      case DeliveryFrequency.monthly:
        return DateTime.now().add(const Duration(days: 30));
    }
    return null;
  }

  double _calculateTotalAmount(
    SubscriptionPlan plan,
    List<SubscriptionItem> items,
  ) {
    double itemsTotal = items.fold(
      0,
      (sum, item) => sum + item.pricePerDelivery,
    );
    return plan.price + itemsTotal;
  }

  void _generateDeliverySchedule(UserSubscription subscription) {
    // Generate delivery schedules based on subscription items
    final deliveries = <DeliverySchedule>[];
    DateTime currentDate = subscription.startDate;

    while (currentDate.isBefore(subscription.endDate)) {
      for (final item in subscription.items) {
        deliveries.add(
          DeliverySchedule(
            id: '${subscription.id}_${currentDate.millisecondsSinceEpoch}',
            subscriptionId: subscription.id,
            deliveryDate: currentDate,
            items: [item],
            status: 'scheduled',
          ),
        );
      }

      // Move to next delivery date based on frequency
      currentDate = _getNextDeliveryDate(
        currentDate,
        subscription.items.first.frequency,
      );
    }

    _deliverySchedules.addAll(deliveries);
  }

  DateTime _getNextDeliveryDate(
    DateTime currentDate,
    DeliveryFrequency frequency,
  ) {
    switch (frequency) {
      case DeliveryFrequency.daily:
        return currentDate.add(const Duration(days: 1));
      case DeliveryFrequency.everyOtherDay:
        return currentDate.add(const Duration(days: 2));
      case DeliveryFrequency.weekly:
        return currentDate.add(const Duration(days: 7));
      case DeliveryFrequency.biWeekly:
        return currentDate.add(const Duration(days: 14));
      case DeliveryFrequency.monthly:
        return currentDate.add(const Duration(days: 30));
    }
  }

  List<SubscriptionPlan> _getInitialPlans() {
    return [
      SubscriptionPlan(
        id: 'daily_fresh',
        name: 'Daily Fresh',
        description: 'Fresh milk, curd, and seasonal fruits delivered daily',
        type: SubscriptionType.daily,
        price: 299.0,
        originalPrice: 399.0,
        durationInDays: 30,
        discount: 25.0,
        isPopular: true,
        features: [
          'Daily fresh milk (500ml)',
          'Fresh curd (200g)',
          'Seasonal fruit bowl',
          'Free home delivery',
          'Quality guarantee',
        ],
        imageUrl: 'assets/images/daily_fresh.png',
      ),
      SubscriptionPlan(
        id: 'weekly_essentials',
        name: 'Weekly Essentials',
        description: 'Weekly delivery of milk, curd, dry fruits, and sprouts',
        type: SubscriptionType.weekly,
        price: 899.0,
        originalPrice: 1199.0,
        durationInDays: 30,
        discount: 25.0,
        features: [
          'Weekly fresh milk (3.5L)',
          'Fresh curd (1kg)',
          'Mixed dry fruits (250g)',
          'Fresh sprouts (500g)',
          'Seasonal fruits',
          'Free home delivery',
        ],
        imageUrl: 'assets/images/weekly_essentials.png',
      ),
      SubscriptionPlan(
        id: 'monthly_premium',
        name: 'Monthly Premium',
        description: 'Complete monthly package with all organic products',
        type: SubscriptionType.monthly,
        price: 2499.0,
        originalPrice: 3299.0,
        durationInDays: 30,
        discount: 24.0,
        features: [
          'Daily organic milk (15L/month)',
          'Fresh curd (3kg/month)',
          'Premium dry fruits (1kg)',
          'Fresh sprouts (2kg)',
          'Seasonal fruit basket',
          'Organic vegetables',
          'Priority delivery',
          'Dedicated support',
        ],
        imageUrl: 'assets/images/monthly_premium.png',
      ),
      SubscriptionPlan(
        id: 'quarterly_family',
        name: 'Quarterly Family Pack',
        description: 'Best value family pack for 3 months',
        type: SubscriptionType.quarterly,
        price: 6999.0,
        originalPrice: 9999.0,
        durationInDays: 90,
        discount: 30.0,
        features: [
          'Daily organic milk (45L/quarter)',
          'Fresh curd (9kg/quarter)',
          'Premium dry fruits (3kg)',
          'Fresh sprouts (6kg)',
          'Weekly fruit baskets',
          'Organic vegetables',
          'Ghee & butter',
          'Free delivery & setup',
          '24/7 customer support',
        ],
        imageUrl: 'assets/images/quarterly_family.png',
      ),
      SubscriptionPlan(
        id: 'yearly_premium',
        name: 'Yearly Premium',
        description: 'Ultimate annual subscription with maximum savings',
        type: SubscriptionType.yearly,
        price: 24999.0,
        originalPrice: 39999.0,
        durationInDays: 365,
        discount: 37.5,
        isPopular: true,
        features: [
          'Daily organic milk (180L/year)',
          'Fresh curd (36kg/year)',
          'Premium dry fruits (12kg)',
          'Fresh sprouts (24kg)',
          'Weekly premium fruit baskets',
          'Organic vegetables',
          'Ghee, butter & cheese',
          'Festival special items',
          'Priority delivery',
          'Dedicated relationship manager',
          'Health consultation',
        ],
        imageUrl: 'assets/images/yearly_premium.png',
      ),
    ];
  }
}
