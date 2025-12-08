// Enhanced subscription models based on the documentation

enum PlanType {
  daily,
  alternateDay,
  weekly,
  monthly,
  quarterly,
  halfYearly,
  annual,
  custom,
}

enum DeliveryPattern { daily, alternate, weekly, monthly, custom }

enum SubscriptionStatus { active, paused, completed, cancelled }

enum PaymentMode { online, /* cod, */ wallet }

class CustomDeliveryDate {
  final DateTime date;
  final int quantity;

  CustomDeliveryDate({required this.date, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'qty': quantity};
  }

  factory CustomDeliveryDate.fromJson(Map<String, dynamic> json) {
    return CustomDeliveryDate(
      date: DateTime.parse(json['date']),
      quantity: json['qty'],
    );
  }
}

class AdvancedSubscription {
  final String subscriptionId;
  final String userId;
  final String productId;
  final String productName;
  final String unit;
  final double pricePerUnit;
  final DateTime startDate;
  final DateTime endDate;
  final PlanType planType;
  final DeliveryPattern deliveryPattern;
  final List<String> weeklyDays; // ["Mon", "Wed", "Fri"]
  final List<CustomDeliveryDate> customDates;
  final int defaultQty;
  final SubscriptionStatus status;
  final List<DateTime> pauseDates;
  final PaymentMode paymentMode;
  final double totalAmount;
  final int remainingDeliveries;
  final String deliveryAddress;
  final String? deliveryInstructions;
  final DateTime createdAt;
  final DateTime? pausedAt;
  final DateTime? resumedAt;

  AdvancedSubscription({
    required this.subscriptionId,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.pricePerUnit,
    required this.startDate,
    required this.endDate,
    required this.planType,
    required this.deliveryPattern,
    this.weeklyDays = const [],
    this.customDates = const [],
    this.defaultQty = 1,
    required this.status,
    this.pauseDates = const [],
    required this.paymentMode,
    required this.totalAmount,
    required this.remainingDeliveries,
    required this.deliveryAddress,
    this.deliveryInstructions,
    required this.createdAt,
    this.pausedAt,
    this.resumedAt,
  });

  // Getters
  bool get isActive => status == SubscriptionStatus.active;
  bool get isPaused => status == SubscriptionStatus.paused;
  bool get isCompleted => status == SubscriptionStatus.completed;
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  double get completionPercentage {
    final totalDays = endDate.difference(startDate).inDays;
    final elapsedDays = DateTime.now().difference(startDate).inDays;
    return (elapsedDays / totalDays * 100).clamp(0, 100);
  }

  // Calculate next delivery date
  DateTime? get nextDeliveryDate {
    if (!isActive) return null;

    final today = DateTime.now();
    switch (deliveryPattern) {
      case DeliveryPattern.daily:
        return _getNextDailyDelivery(today);
      case DeliveryPattern.alternate:
        return _getNextAlternateDelivery(today);
      case DeliveryPattern.weekly:
        return _getNextWeeklyDelivery(today);
      case DeliveryPattern.monthly:
        return _getNextMonthlyDelivery(today);
      case DeliveryPattern.custom:
        return _getNextCustomDelivery(today);
      default:
        return null;
    }
  }

  DateTime? _getNextDailyDelivery(DateTime from) {
    DateTime next = DateTime(from.year, from.month, from.day + 1);
    while (pauseDates.contains(next) && next.isBefore(endDate)) {
      next = next.add(const Duration(days: 1));
    }
    return next.isBefore(endDate) ? next : null;
  }

  DateTime? _getNextAlternateDelivery(DateTime from) {
    DateTime next = DateTime(from.year, from.month, from.day + 2);
    while (pauseDates.contains(next) && next.isBefore(endDate)) {
      next = next.add(const Duration(days: 2));
    }
    return next.isBefore(endDate) ? next : null;
  }

  DateTime? _getNextWeeklyDelivery(DateTime from) {
    if (weeklyDays.isEmpty) return null;

    final weekdayMap = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
    };

    final targetWeekdays =
        weeklyDays
            .map((day) => weekdayMap[day])
            .where((day) => day != null)
            .cast<int>()
            .toList()
          ..sort();

    DateTime next = from.add(const Duration(days: 1));
    while (next.isBefore(endDate)) {
      if (targetWeekdays.contains(next.weekday) && !pauseDates.contains(next)) {
        return next;
      }
      next = next.add(const Duration(days: 1));
    }
    return null;
  }

  DateTime? _getNextMonthlyDelivery(DateTime from) {
    final nextMonth = DateTime(from.year, from.month + 1, startDate.day);
    return nextMonth.isBefore(endDate) && !pauseDates.contains(nextMonth)
        ? nextMonth
        : null;
  }

  DateTime? _getNextCustomDelivery(DateTime from) {
    final upcomingDates =
        customDates
            .where(
              (cd) => cd.date.isAfter(from) && !pauseDates.contains(cd.date),
            )
            .map((cd) => cd.date)
            .toList()
          ..sort();

    return upcomingDates.isNotEmpty ? upcomingDates.first : null;
  }

  // Generate delivery schedule for a date range
  List<DeliveryScheduleItem> generateDeliverySchedule(
    DateTime from,
    DateTime to,
  ) {
    final schedule = <DeliveryScheduleItem>[];

    switch (deliveryPattern) {
      case DeliveryPattern.daily:
        schedule.addAll(_generateDailySchedule(from, to));
        break;
      case DeliveryPattern.alternate:
        schedule.addAll(_generateAlternateSchedule(from, to));
        break;
      case DeliveryPattern.weekly:
        schedule.addAll(_generateWeeklySchedule(from, to));
        break;
      case DeliveryPattern.monthly:
        schedule.addAll(_generateMonthlySchedule(from, to));
        break;
      case DeliveryPattern.custom:
        schedule.addAll(_generateCustomSchedule(from, to));
        break;
    }

    return schedule;
  }

  List<DeliveryScheduleItem> _generateDailySchedule(
    DateTime from,
    DateTime to,
  ) {
    final schedule = <DeliveryScheduleItem>[];
    DateTime current = from;

    while (current.isBefore(to) && current.isBefore(endDate)) {
      if (!pauseDates.contains(current)) {
        schedule.add(
          DeliveryScheduleItem(
            date: current,
            productName: productName,
            unit: unit,
            quantity: defaultQty,
            subscriptionId: subscriptionId,
          ),
        );
      }
      current = current.add(const Duration(days: 1));
    }

    return schedule;
  }

  List<DeliveryScheduleItem> _generateAlternateSchedule(
    DateTime from,
    DateTime to,
  ) {
    final schedule = <DeliveryScheduleItem>[];
    DateTime current = startDate;

    // Find the first delivery date from the start
    while (current.isBefore(from)) {
      current = current.add(const Duration(days: 2));
    }

    while (current.isBefore(to) && current.isBefore(endDate)) {
      if (!pauseDates.contains(current)) {
        schedule.add(
          DeliveryScheduleItem(
            date: current,
            productName: productName,
            unit: unit,
            quantity: defaultQty,
            subscriptionId: subscriptionId,
          ),
        );
      }
      current = current.add(const Duration(days: 2));
    }

    return schedule;
  }

  List<DeliveryScheduleItem> _generateWeeklySchedule(
    DateTime from,
    DateTime to,
  ) {
    final schedule = <DeliveryScheduleItem>[];
    final weekdayMap = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
    };

    final targetWeekdays = weeklyDays
        .map((day) => weekdayMap[day])
        .where((day) => day != null)
        .cast<int>()
        .toSet();

    DateTime current = from;
    while (current.isBefore(to) && current.isBefore(endDate)) {
      if (targetWeekdays.contains(current.weekday) &&
          !pauseDates.contains(current)) {
        schedule.add(
          DeliveryScheduleItem(
            date: current,
            productName: productName,
            unit: unit,
            quantity: defaultQty,
            subscriptionId: subscriptionId,
          ),
        );
      }
      current = current.add(const Duration(days: 1));
    }

    return schedule;
  }

  List<DeliveryScheduleItem> _generateMonthlySchedule(
    DateTime from,
    DateTime to,
  ) {
    final schedule = <DeliveryScheduleItem>[];
    DateTime current = DateTime(from.year, from.month, startDate.day);

    while (current.isBefore(to) && current.isBefore(endDate)) {
      if (current.isAfter(from) && !pauseDates.contains(current)) {
        schedule.add(
          DeliveryScheduleItem(
            date: current,
            productName: productName,
            unit: unit,
            quantity: defaultQty,
            subscriptionId: subscriptionId,
          ),
        );
      }
      current = DateTime(current.year, current.month + 1, startDate.day);
    }

    return schedule;
  }

  List<DeliveryScheduleItem> _generateCustomSchedule(
    DateTime from,
    DateTime to,
  ) {
    return customDates
        .where(
          (cd) =>
              cd.date.isAfter(from) &&
              cd.date.isBefore(to) &&
              cd.date.isBefore(endDate) &&
              !pauseDates.contains(cd.date),
        )
        .map(
          (cd) => DeliveryScheduleItem(
            date: cd.date,
            productName: productName,
            unit: unit,
            quantity: cd.quantity,
            subscriptionId: subscriptionId,
          ),
        )
        .toList();
  }

  // Copy with method
  AdvancedSubscription copyWith({
    String? subscriptionId,
    String? userId,
    String? productId,
    String? productName,
    String? unit,
    double? pricePerUnit,
    DateTime? startDate,
    DateTime? endDate,
    PlanType? planType,
    DeliveryPattern? deliveryPattern,
    List<String>? weeklyDays,
    List<CustomDeliveryDate>? customDates,
    int? defaultQty,
    SubscriptionStatus? status,
    List<DateTime>? pauseDates,
    PaymentMode? paymentMode,
    double? totalAmount,
    int? remainingDeliveries,
    String? deliveryAddress,
    String? deliveryInstructions,
    DateTime? createdAt,
    DateTime? pausedAt,
    DateTime? resumedAt,
  }) {
    return AdvancedSubscription(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      planType: planType ?? this.planType,
      deliveryPattern: deliveryPattern ?? this.deliveryPattern,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      customDates: customDates ?? this.customDates,
      defaultQty: defaultQty ?? this.defaultQty,
      status: status ?? this.status,
      pauseDates: pauseDates ?? this.pauseDates,
      paymentMode: paymentMode ?? this.paymentMode,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingDeliveries: remainingDeliveries ?? this.remainingDeliveries,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      createdAt: createdAt ?? this.createdAt,
      pausedAt: pausedAt ?? this.pausedAt,
      resumedAt: resumedAt ?? this.resumedAt,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'planType': planType.toString(),
      'deliveryPattern': deliveryPattern.toString(),
      'weeklyDays': weeklyDays,
      'customDates': customDates.map((cd) => cd.toJson()).toList(),
      'defaultQty': defaultQty,
      'status': status.toString(),
      'pauseDates': pauseDates.map((d) => d.toIso8601String()).toList(),
      'paymentMode': paymentMode.toString(),
      'totalAmount': totalAmount,
      'remainingDeliveries': remainingDeliveries,
      'deliveryAddress': deliveryAddress,
      'deliveryInstructions': deliveryInstructions,
      'createdAt': createdAt.toIso8601String(),
      'pausedAt': pausedAt?.toIso8601String(),
      'resumedAt': resumedAt?.toIso8601String(),
    };
  }
}

class DeliveryScheduleItem {
  final DateTime date;
  final String productName;
  final String unit;
  final int quantity;
  final String subscriptionId;
  final String status;
  final DateTime? deliveredAt;
  final String? deliveryNotes;

  DeliveryScheduleItem({
    required this.date,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.subscriptionId,
    this.status = 'scheduled',
    this.deliveredAt,
    this.deliveryNotes,
  });

  bool get isDelivered => status == 'delivered';
  bool get isScheduled => status == 'scheduled';
  bool get isMissed => status == 'missed';
  bool get isCancelled => status == 'cancelled';

  DeliveryScheduleItem copyWith({
    DateTime? date,
    String? productName,
    String? unit,
    int? quantity,
    String? subscriptionId,
    String? status,
    DateTime? deliveredAt,
    String? deliveryNotes,
  }) {
    return DeliveryScheduleItem(
      date: date ?? this.date,
      productName: productName ?? this.productName,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
    );
  }
}

// Subscription plan templates
class SubscriptionPlanTemplate {
  final PlanType planType;
  final String name;
  final String description;
  final int durationInDays;
  final double discountPercentage;
  final List<String> features;

  SubscriptionPlanTemplate({
    required this.planType,
    required this.name,
    required this.description,
    required this.durationInDays,
    required this.discountPercentage,
    required this.features,
  });

  static List<SubscriptionPlanTemplate> getDefaultPlans() {
    return [
      // SubscriptionPlanTemplate(
      //   planType: PlanType.daily,
      //   name: 'Daily Delivery',
      //   description: 'Fresh delivery every day',
      //   durationInDays: 30,
      //   discountPercentage: 0,
      //   features: ['Daily fresh delivery', 'Flexible pause/resume', 'No commitment'],
      // ),
      // SubscriptionPlanTemplate(
      //   planType: PlanType.weekly,
      //   name: 'Weekly Plan',
      //   description: 'Choose your delivery days',
      //   durationInDays: 30,
      //   discountPercentage: 5,
      //   features: ['Choose delivery days', '5% discount', 'Flexible scheduling'],
      // ),
      SubscriptionPlanTemplate(
        planType: PlanType.monthly,
        name: 'Monthly Plan',
        description: 'Full month subscription',
        durationInDays: 30,
        discountPercentage: 10,
        features: ['10% discount', 'Priority delivery', 'Free pause/resume'],
      ),
      SubscriptionPlanTemplate(
        planType: PlanType.quarterly,
        name: 'Quarterly Plan',
        description: '3 months of savings',
        durationInDays: 90,
        discountPercentage: 15,
        features: ['15% discount', 'Priority support', 'Free delivery'],
      ),
      SubscriptionPlanTemplate(
        planType: PlanType.halfYearly,
        name: 'Half-Yearly Plan',
        description: '6 months of maximum savings',
        durationInDays: 180,
        discountPercentage: 20,
        features: [
          '20% discount',
          'VIP support',
          'Free delivery',
          'Bonus gifts',
        ],
      ),
      SubscriptionPlanTemplate(
        planType: PlanType.annual,
        name: 'Annual Plan',
        description: 'Best value for a full year',
        durationInDays: 365,
        discountPercentage: 25,
        features: [
          '25% discount',
          'VIP support',
          'Free delivery',
          'Monthly bonus',
        ],
      ),
    ];
  }
}
