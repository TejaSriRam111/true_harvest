// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/auth_controller.dart';
import 'package:task_new/controllers/location_provider.dart';
import 'package:task_new/screens/auth/otp_screen.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/utils/app_constants.dart';
import 'package:task_new/widgets/custom_floating_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // country code is implied; API expects raw 10-digit mobile
  String? _phoneError;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

 
  @override
  Widget build(BuildContext context) {
    final authViewController = ref.watch(authProvider);
    final isLoading = ref.watch(authProvider.select((val) => val.isLoading));

    return Scaffold(
      resizeToAvoidBottomInset: true,

      backgroundColor: const Color(0xFFFAF3E6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),

                Image.asset(AppConstants.onBoardingScreenAssert, height: 150),

                const SizedBox(height: 5),

                const Text(
                  "Freshness You Can Trust, Purity You Can Taste",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.darkGreen),
                ),

                const SizedBox(height: 40),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Mobile Number", style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "+91",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                      

                        decoration: InputDecoration(
                          
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter 10 digit number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        
                          
                          errorText: _phoneError,
                        ),

                        onChanged: (value) {
                          ref.read(authProvider).updateMobile(value);
                          // setState(() {
                          //   if (value.isEmpty) {
                          //     _phoneError = "Please enter your phone number";
                          //   } else if (value.length < 10) {
                          //     _phoneError = "Please enter a valid phone number";
                          //   } else {
                          //     _phoneError = null; // No error
                          //   }
                          // });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : authViewController.mobileNumber.length == 10
                      ? _onSubmit
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: authViewController.mobileNumber.length == 10 && !isLoading
                        ? AppColors.darkGreen
                        : Colors.grey.shade400,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: AppColors.lightBackground,
                        )
                      : Text("Send OTP", style: TextStyle(fontSize: 18)),
                ),

                const Spacer(),

                const Text(
                  "By continuing, you agree to our\nTerms & Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
   void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final rawMobile = _textController.text.trim();

      try {
        // Use raw 10-digit mobile (no +91 prefix) as requested
        // ref.read(authProvider).updateMobile(rawMobile);

        // Use API-based WhatsApp OTP flow with raw mobile
        final sent = await ref.read(authProvider).sendOtpViaApi(rawMobile);

        if (!mounted) return;

        if (sent) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OtpScreen()),
          );
                              Future(() => ref.read(locationProvider.notifier).getCurrentLocation());

        } /* else {
          CustomFloatingToast.showToast("Failed to send OTP. Try again.");
        } */
      } catch (e) {
        if (mounted) {
          CustomFloatingToast.showToast("Failed to send OTP. Try again.");
 
        }
      }
    }
  }

}
