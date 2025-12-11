// Clean single `AuthProvider` implementation — used by login/OTP screens
// NOTE: we use client-side OTP matching against the last API response's `otp` value.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_new/models/user_profile_model.dart';
import 'package:task_new/services/auth_service.dart';
import 'package:task_new/widgets/custom_floating_toast.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // UI / flow state
  int timer = 30;
  String? _verificationId;

  // API OTP state (WhatsApp send)
  String? apiOtp; // last OTP returned by send API
  DateTime? otpSentAt;
  String? lastSendMessage;
  bool otpRequested = false;
  String? lastVerifyMessage;
  //setters
  UserProfile? _userProfile;
  bool _isLoading = false;
  String mobileNumber = "";

  //getters
  UserProfile? get userProfile => _userProfile;

  bool get isLoading => _isLoading;
  String? get verificationId => _verificationId;
  AuthService get otpService => _authService;

  void updateMobile(String value) {
    mobileNumber = value;
    notifyListeners();
  }

  Future<bool> sendOtpViaApi(
    String phoneNumber, {
    String appName = 'true harvest',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      mobileNumber = phoneNumber;
      otpRequested = true;
      notifyListeners();

      final data = await _authService.sendWhatsAppOtp(
        mobile: phoneNumber,
        appName: appName,
      );
      if (data.isNotEmpty) {
        CustomFloatingToast.showToast(data["message"]);
        _userProfile = UserProfile.fromJson(
          data["user"] as Map<String, dynamic>,
        );
      }
      debugPrint('OTP API response: ${data.toString()}');

      // Prefer top-level `otp`, fallback to nested `user.otp` when present
      final topLevel = data['otp']?.toString();
      final nested =
          (data['user'] != null &&
              data['user'] is Map &&
              (data['user'] as Map)['otp'] != null)
          ? (data['user'] as Map)['otp'].toString()
          : null;

      apiOtp = topLevel ?? nested;
      otpSentAt = DateTime.now();

   
      lastSendMessage = data['message']?.toString();

      startTimer();
      return true;
    } catch (e) {
      debugPrint('Error sending OTP via API: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyApiOtp(String otp) async {
    try {
      _isLoading = true;
      notifyListeners();
      final entered = otp.toString();
      final expected = apiOtp?.toString();
      final success = expected != null && entered == expected;

      debugPrint(
        'Client OTP verification: entered=$entered, expected=$expected, success=$success',
      );

      if (success) {
        otpRequested = false;
        apiOtp = null;
        otpSentAt = null;
      } else {
        CustomFloatingToast.showToast(
          'OTP does not match. Please enter the correct OTP.',
        );
        // lastVerifyMessage = 'OTP does not match. Please enter the correct OTP.';
      }

      return success;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfile({
    String? name,
    String? email,
    String? firstName,
    String? lastName,
    String? address,
    String? gender,
    String? dateOfBirth,

    
  }) {
    _userProfile = _userProfile?.copyWith(
      name: name,
      email: email,
      firstName: firstName,
      lastName: lastName,

      address: address,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
    notifyListeners();
  }

  Future<bool> updateUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();
      final rawData = await _authService.updateUserProfile(
        mobile: mobileNumber,
        profileData: _userProfile!.toJson(),
      );
      if (rawData['user'].isNotEmpty&&rawData["status"]=="success") {
        CustomFloatingToast.showToast(rawData['message'] ?? 'Registration successful');
        _userProfile=UserProfile.fromJson(
          rawData['user'],
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  void startTimer() {
    timer = 30;
    notifyListeners();

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (timer == 0) return false;
      timer--;
      notifyListeners();
      return true;
    });
  }

  Future<bool> resendOtp() async {
    if (mobileNumber.isEmpty) return false;
    return await sendOtpViaApi(mobileNumber, appName: 'true harvest');
  }

  /// Returns true on success, false otherwise.
}
