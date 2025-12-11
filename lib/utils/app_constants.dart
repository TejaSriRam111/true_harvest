import 'package:flutter/material.dart';

class AppConstants {
  static const String kAppName = "TrueHarvest";
  static const String appLogoAssert = "assets/app_logo.png";
  static const String onBoardingScreenAssert = "assets/onboarding_logo.jpeg";

  // API Configuration
  static const String apiUrl =
      'https://markwave-live-services-couipk45fa-el.a.run.app';
      
  static const String applicationJson = "application/json";
//OTP API
static const otpUrl = 'https://markwave-live-apis-couipk45fa-el.a.run.app/otp/send-whatsapp';
  // Discount Configuration
  static const double minimumOrderForDiscount = 500.0;
  static const double discountPercentage = 0.10; // 10%
  static const double minimumMilkQuantity = 1.0; // 1 liter



}
enum CategoryType {
  milk,
  curd,
  butter,
  fruit,
  dryFruits,
  sprouts,
  honey,
  paneer,
}


extension CategoryTypeExtension on CategoryType{
  bool get isMilk => this == CategoryType.milk;
  bool get isCurd => this == CategoryType.curd;
  bool get isButter => this == CategoryType.butter;
  bool get issprouts=>this==CategoryType.sprouts;
  bool get isdryFruits=>this==CategoryType.dryFruits;
  bool get isfruit=>this==CategoryType.fruit;

}
