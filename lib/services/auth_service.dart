import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:task_new/utils/app_constants.dart';
import 'package:task_new/widgets/custom_floating_toast.dart';

class AuthService {


  Future<Map<String, dynamic>> sendWhatsAppOtp({
    required String mobile,
    required String appName,
  }) async {
    final body = jsonEncode({'mobile': mobile, 'appName': appName});
    try {
      final response = await http.post(
        Uri.parse(AppConstants.otpUrl),
        headers: {HttpHeaders.contentTypeHeader: AppConstants.applicationJson},
        body: body,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["user"] != null) {
         return data;
        }else{
          return {};
        }

      }
    } catch (error) {
      debugPrint('OTP send error: $error');
    }
    return {};
  }

 Future<Map<String, dynamic>> updateUserProfile({
    required String mobile,
    required Map<String, dynamic> profileData,
  }) async {

    try {
      final body = jsonEncode(profileData);

      final response = await http.put(
        Uri.parse("https://markwave-live-apis-couipk45fa-el.a.run.app/users/$mobile"),
        headers: {HttpHeaders.contentTypeHeader: AppConstants.applicationJson},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['user'] != null) {
          return data;
        }

      } else {
        debugPrint('updateUserProfile failed: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('updateUserProfile error: $e');
      return {};
    } 
    return {};
  }


}
