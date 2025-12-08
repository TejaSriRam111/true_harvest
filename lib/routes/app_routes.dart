import 'package:flutter/material.dart';
import 'package:task_new/screens/auth/auth_wrapper.dart';
import 'package:task_new/screens/auth/login_screen.dart';
import 'package:task_new/screens/auth/otp_screen.dart';
import 'package:task_new/screens/cart_screen.dart';
import 'package:task_new/screens/home_screen.dart';
import 'package:task_new/screens/main_screen.dart';
import 'package:task_new/screens/onboarding/splash_screen.dart';
import 'package:task_new/screens/product_details_view.dart';
import 'package:task_new/screens/profile_screen.dart';
import 'package:task_new/screens/delivery_schedule_screen.dart';
import 'package:task_new/screens/checkout_screen.dart';
import 'package:task_new/screens/payment_success_screen.dart';
import 'package:task_new/screens/wishlist_screen.dart';
import 'package:task_new/models/product_model.dart';
import 'package:task_new/models/subscription_model.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String authWrapper = '/auth-wrapper';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String main = '/main';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String paymentSuccess = '/payment-success';
  static const String productDetails = '/product-details';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static const String subscriptionPlans = '/subscription-plans';
  static const String customSubscription = '/custom-subscription';
  static const String subscriptionDetails = '/subscription-details';
  static const String deliverySchedule = '/delivery-schedule';
  static const String subscriptionManagement = '/subscription-management';
  static const String wishlist = '/wishlist';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case authWrapper:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );

      case otp:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OtpScreen(
            // phoneNumber: args?['phoneNumber'] ?? '',
            // verificationId: args?['verificationId'] ?? '',
          ),
          settings: settings,
        );

      case main:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case cart:
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
          settings: settings,
        );

      case checkout:
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreen(),
          settings: settings,
        );

      case paymentSuccess:
        return MaterialPageRoute(
          builder: (_) => const PaymentSuccessScreen(),
          settings: settings,
        );

      case productDetails:
        final product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (_) => ProductDetailsView(product: product),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case deliverySchedule:
        return MaterialPageRoute(
          builder: (_) => const DeliveryScheduleScreen(),
          settings: settings,
        );

      case wishlist:
        return MaterialPageRoute(
          builder: (_) => const WishlistScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(child: Text('Page not found!')),
          ),
          settings: settings,
        );
    }
  }

  // Navigation helper methods
  static Future<void> navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static Future<void> navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<void> navigateAndClearStack(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  // Specific navigation methods for common flows
  static Future<void> goToLogin(BuildContext context) {
    return navigateAndReplace(context, login);
  }

  static Future<void> goToMain(BuildContext context) {
    return navigateAndClearStack(context, main);
  }

  static Future<void> goToCart(BuildContext context) {
    return navigateTo(context, cart);
  }

  static Future<void> goToProductDetails(
    BuildContext context,
    Product product,
  ) {
    return navigateTo(context, productDetails, arguments: product);
  }

  static Future<void> goToOtp(
    BuildContext context,
    String phoneNumber,
    String verificationId,
  ) {
    return navigateTo(
      context,
      otp,
      arguments: {'phoneNumber': phoneNumber, 'verificationId': verificationId},
    );
  }
}
