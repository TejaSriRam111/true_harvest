import 'package:task_new/models/product_model.dart';

enum SubscriptionType { daily, weekly, monthly, quarterly, yearly }

enum SubscriptionStatus { active, paused, cancelled, expired }

enum DeliveryFrequency { daily, everyOtherDay, weekly, biWeekly, monthly }

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final SubscriptionType type;
  final double price;
  final double originalPrice;
  final int durationInDays;
  final List<String> features;
  final String imageUrl;
  final bool isPopular;
  final double discount;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.originalPrice,
    required this.durationInDays,
    required this.features,
    required this.imageUrl,
    this.isPopular = false,
    required this.discount,
  });

  double get discountPercentage =>
      ((originalPrice - price) / originalPrice) * 100;

  SubscriptionPlan copyWith({
    String? id,
    String? name,
    String? description,
    SubscriptionType? type,
    double? price,
    double? originalPrice,
    int? durationInDays,
    List<String>? features,
    String? imageUrl,
    bool? isPopular,
    double? discount,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      durationInDays: durationInDays ?? this.durationInDays,
      features: features ?? this.features,
      imageUrl: imageUrl ?? this.imageUrl,
      isPopular: isPopular ?? this.isPopular,
      discount: discount ?? this.discount,
    );
  }
}

class SubscriptionItem {
  final String id;
  final Product product;
  final String unit;
  final int quantity;
  final DeliveryFrequency frequency;
  final double pricePerDelivery;

  SubscriptionItem({
    required this.id,
    required this.product,
    required this.unit,
    required this.quantity,
    required this.frequency,
    required this.pricePerDelivery,
  });

  SubscriptionItem copyWith({
    String? id,
    Product? product,
    String? unit,
    int? quantity,
    DeliveryFrequency? frequency,
    double? pricePerDelivery,
  }) {
    return SubscriptionItem(
      id: id ?? this.id,
      product: product ?? this.product,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      frequency: frequency ?? this.frequency,
      pricePerDelivery: pricePerDelivery ?? this.pricePerDelivery,
    );
  }
}

class UserSubscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final List<SubscriptionItem> items;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? nextDeliveryDate;
  final SubscriptionStatus status;
  final String deliveryAddress;
  final String deliveryInstructions;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? pausedAt;
  final DateTime? cancelledAt;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.items,
    required this.startDate,
    required this.endDate,
    this.nextDeliveryDate,
    required this.status,
    required this.deliveryAddress,
    this.deliveryInstructions = '',
    required this.totalAmount,
    required this.createdAt,
    this.pausedAt,
    this.cancelledAt,
  });

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPaused => status == SubscriptionStatus.paused;
  bool get isCancelled => status == SubscriptionStatus.cancelled;
  bool get isExpired =>
      status == SubscriptionStatus.expired || DateTime.now().isAfter(endDate);

  int get daysRemaining {
    if (isExpired || isCancelled) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  UserSubscription copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    List<SubscriptionItem>? items,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDeliveryDate,
    SubscriptionStatus? status,
    String? deliveryAddress,
    String? deliveryInstructions,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? pausedAt,
    DateTime? cancelledAt,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      items: items ?? this.items,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDeliveryDate: nextDeliveryDate ?? this.nextDeliveryDate,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      pausedAt: pausedAt ?? this.pausedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}

class DeliverySchedule {
  final String id;
  final String subscriptionId;
  final DateTime deliveryDate;
  final List<SubscriptionItem> items;
  final String status; // scheduled, delivered, missed, cancelled
  final String? deliveryNotes;
  final DateTime? deliveredAt;

  DeliverySchedule({
    required this.id,
    required this.subscriptionId,
    required this.deliveryDate,
    required this.items,
    required this.status,
    this.deliveryNotes,
    this.deliveredAt,
  });

  bool get isDelivered => status == 'delivered';
  bool get isScheduled => status == 'scheduled';
  bool get isMissed => status == 'missed';

  DeliverySchedule copyWith({
    String? id,
    String? subscriptionId,
    DateTime? deliveryDate,
    List<SubscriptionItem>? items,
    String? status,
    String? deliveryNotes,
    DateTime? deliveredAt,
  }) {
    return DeliverySchedule(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      items: items ?? this.items,
      status: status ?? this.status,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
