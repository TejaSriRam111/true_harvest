import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_new/controllers/cart_controller.dart';
import 'package:task_new/services/user_verification_service.dart';

final verificationServiceProvider =
    ChangeNotifierProvider<UserVerificationService>((ref) {
      return UserVerificationService();
    });

// Provider for checking discount eligibility
final discountEligibilityProvider = Provider.family<bool, Map<String, dynamic>>(
  (ref, params) {
    final verificationService = ref.watch(verificationServiceProvider);
    final cartItems = params['cartItems'] as List<dynamic>;
    final totalAmount = params['totalAmount'] as double;

    return verificationService.isEligibleForDiscount(cartItems, totalAmount);
  },
);

// Provider for calculating discount amount
final discountAmountProvider = Provider.family<double, double>((
  ref,
  totalAmount,
) {
  final verificationService = ref.watch(verificationServiceProvider);
  final cartItems = ref.watch(cartProvider).items;

  if (verificationService.isEligibleForDiscount(cartItems, totalAmount)) {
    return verificationService.calculateDiscount(totalAmount);
  }
  return 0.0;
});

// Import cart provider (assuming it exists)
// You'll need to import your existing cart provider here
