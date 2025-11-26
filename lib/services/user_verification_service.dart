import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:task_new/models/user_profile_model.dart';
import 'package:task_new/services/api_services.dart';
import 'package:task_new/utils/app_constants.dart';

class UserVerificationService extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isVerified = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isVerified => _isVerified;

  // Verify user from Animal Kart app
  Future<bool> verifyUser(String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final deviceDetails = await ApiServices.fetchDeviceDetails();
      final response = await http.post(
        Uri.parse("${AppConstants.apiUrl}/users/verify"),
        headers: {HttpHeaders.contentTypeHeader: AppConstants.applicationJson},
        body: jsonEncode({
          'mobile': phone,
          'device_id': deviceDetails.id,
          'device_model': deviceDetails.model,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final bool isSuccess = data["status"] == "success";

        if (isSuccess && data["user"] != null) {
          _userProfile = UserProfile.fromJson(
            data["user"] as Map<String, dynamic>,
          );
          _isVerified = true;
          debugPrint('User verified: $_userProfile');
        }

        return isSuccess;
      } else {
        return false;
      }
    } catch (error) {
      debugPrint('Verification error: $error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user is eligible for 10% discount
  bool isEligibleForDiscount(List<dynamic> cartItems, double totalAmount) {
    // Minimum order amount should be 500 rupees
    if (totalAmount < 500) {
      return false;
    }

    // Check if user is verified
    if (!_isVerified) {
      return false;
    }

    // Check specific product conditions
    bool hasMilk = false;
    bool hasFruit = false;
    double milkQuantity = 0;

    for (var item in cartItems) {
      String productName = item.product.name.toLowerCase();
      
      // Check for milk (at least 1 liter)
      if (productName.contains('milk')) {
        if (item.selectedUnit.toLowerCase().contains('liter') || 
            item.selectedUnit.toLowerCase().contains('l')) {
          milkQuantity += item.quantity;
        }
      }

      // Check for fruits
      if (productName.contains('fruit') || 
          item.product.category.toLowerCase().contains('fruit')) {
        hasFruit = true;
      }
    }

    hasMilk = milkQuantity >= 1; // At least 1 liter of milk

    return hasMilk && hasFruit;
  }

  // Calculate discount amount
  double calculateDiscount(double totalAmount) {
    if (!_isVerified) return 0;
    return totalAmount * 0.10; // 10% discount
  }

  // Get discount offer message
  String getDiscountOfferMessage() {
    if (!_isVerified) {
      return "Verify your Animal Kart account to get 10% discount!";
    }
    return "🎉 Animal Kart User: Get 10% OFF on orders above ₹500 with 1L milk + fruits!";
  }

  // Clear verification data
  void clearVerification() {
    _userProfile = null;
    _isVerified = false;
    notifyListeners();
  }
}
