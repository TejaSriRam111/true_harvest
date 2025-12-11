import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/auth_controller.dart';
import 'package:task_new/screens/auth/registration_screen.dart';
import 'package:task_new/screens/main_screen.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/utils/app_constants.dart';
import 'package:task_new/widgets/custom_floating_toast.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  late final AuthProvider _authController=ref.read(authProvider);

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

 @override
  void initState() {
    super.initState();
    // Focus on the first OTP field when screen loads
  }

  

  @override
  Widget build(BuildContext context) {
    final viewController = ref.watch(authProvider);
    final isLoading = ref.watch(authProvider.select((val) => val.isLoading));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Image.asset(AppConstants.onBoardingScreenAssert, height: 150),

                  const SizedBox(height: 5),
                  const Text(
                    "Freshness You Can Trust, Purity You Can Taste",

                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.darkGreen, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter OTP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [Text("OTP sent to +91 ${_authController.mobileNumber}")],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (index) => SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) => _onOtpChanged(value, index),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  viewController.timer > 0
                      ? Text("Resend OTP in ${viewController.timer}s")
                      : TextButton(
                          onPressed: () async {
                            // call resend and show message
                            final provider = ref.read(authProvider);
                            final success = await provider.resendOtp();
                            final message = provider.lastSendMessage ?? (success ? 'OTP sent' : 'Failed to send OTP');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            }
                          },
                          child: const Text("Resend OTP"),
                        ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Consumer(builder: (ctx, ref2, _) {
                      final auth = ref2.watch(authProvider);
                        final canVerify = !isLoading && auth.otpRequested && auth.mobileNumber.length == 10;

                      return ElevatedButton(
                        onPressed: canVerify ? _verifyOtp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B2E),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                "Verify & Login",
                                style: TextStyle(fontSize: 18),
                              ),
                      );
                    }),
                    ),
                  
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.darkGreen,
                          width: 1,
                        ),
                        minimumSize: const Size(double.infinity, 56),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.transparent, 
                      ),
                      child: const Text(
                        "Change Number",
                        style: TextStyle(
                          color: AppColors.darkGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "By continuing, you agree to our\nTerms & Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

    void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }
   Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      final otp = _otpControllers.map((e) => e.text).join();

        final ok = await _authController.verifyApiOtp(otp);
        if (ok) {

          if (mounted) {
            if(ref.read(authProvider).userProfile != null && ref.read(authProvider).userProfile!.isFormFilled == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen()
              ),
            );

          }} else {
            // Navigate to registration screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>  RegistrationScreen(
                  phoneNumber: _authController.mobileNumber,
                ),
              ),
            );
          }
        }else{
          CustomFloatingToast.showToast('Invalid OTP. Please try again.');
        }
    
    }
  }
}
