import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/auth_controller.dart';
import 'package:task_new/controllers/location_provider.dart';
import 'package:task_new/screens/main_screen.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/widgets/custom_floating_toast.dart';
import 'package:task_new/widgets/custom_textfield.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const RegistrationScreen({required this.phoneNumber, super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen>  {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

final TextEditingController _phoneNumberController = TextEditingController();
 final TextEditingController _firstNameController = TextEditingController();
  final  TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
 late AuthProvider authProviderController =ref.read(authProvider);
  bool isAgreedTerms = false;

  @override
  void initState() {
    super.initState();
    _phoneNumberController.text = '+91 ${authProviderController.mobileNumber}';
                final locationViewController = ref.read(locationProvider);
                _addressController.text=locationViewController.detailedAddress?.fullAddress??"";

  }

  // Future<void> _loadAddress() async {

  //   // final formCtrl = ref.read(addressFormProvider);


  //   if (mounted) {
  //     setState(() {
  //       final locationState = ref.read(locationProvider);
  //       if (locationState.detailedAddress != null) {
  //         // formCtrl.loadFromLocation(locationState.detailedAddress!);
  //         _addressController.text = locationState.detailedAddress?.fullAddress ?? '';
  //       }
  //     });
  //   }
  // }
  


  @override
  void dispose() {
    _phoneNumberController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _familyNameController.dispose();
    _occupationController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Register Your Account !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome, Please Enter Your Details.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Contact Information Section
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Phone Number (read-only field reusing CustomTextField styling)
                // We supply a controller with the phone value and mark the field readOnly/disabled
                CustomTextField(
                  label: 'Phone Number',
                  labelText: 'Phone Number ',
                  // show the full displayed value with country code in the controller
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  readOnly: true,

                  validator: (value) {
                    // no validation because it's read-only
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email ID
                CustomTextField(
                  label: 'Email ID',
                  labelText: 'Email ID',
                  hintText: 'Email ID',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  isOptional: true,
                  prefixIcon: Icons.email_outlined,
                  onChanged: (_) => authProviderController.updateProfile(
                    email: _emailController.text,
                  ),

                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Personal Information Section
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // First Name
                CustomTextField(
                  label: 'First Name',
                  labelText: 'First Name',
                  hintText: 'First Name',
                  controller: _firstNameController,
                  onChanged: (_) => authProviderController.updateProfile(
                    firstName: _firstNameController.text,
                  ),

                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Family Name
                CustomTextField(
                  label: 'Family Name',
                  labelText: 'Family Name',
                  hintText: 'Family Name',
                  isOptional: true,
                  controller: _familyNameController,
                  onChanged: (_) => authProviderController.updateProfile(
                    lastName: _familyNameController.text,
                  ),
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Gender
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer(
                      builder: (context, WidgetRef ref, child) {
                        final viewController = ref.watch(authProvider);
                        return Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'Male',
                                     groupValue: viewController.userProfile?.gender??'male',
                                    onChanged: (value) {
                                      if (value != null) {
                                        authProviderController.updateProfile(
                                          gender: value,
                                        );
                                      }
                                    },
                                    activeColor: AppColors.darkGreen,
                                  ),
                                  const Text('Male'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'Female',
                        groupValue: viewController.userProfile?.gender??'male',
                                    onChanged: (value) {
                                      if (value != null) {
                                        authProviderController.updateProfile(
                                          gender: value,
                                        );
                                      }
                                    },
                                    activeColor: AppColors.darkGreen,
                                  ),
                                  const Text('Female'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'Others',
                                    groupValue: viewController.userProfile?.gender??'male',
                                    onChanged: (value) {
                                      if (value != null) {
                                        authProviderController.updateProfile(
                                          gender: value,
                                        );
                                      }
                                    },
                                    activeColor: AppColors.darkGreen,
                                  ),
                                  const Text('Others'),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Date of Birth
                CustomTextField(
                  readOnly: true,
                  label: 'Date of Birth',
                  labelText: 'Date of Birth ',
                  hintText: 'DD/MM/YYYY',
                  controller: _dateOfBirthController,
                  keyboardType: TextInputType.none,
                  suffixIcon: const Icon(Icons.calendar_month),
                  onSuffixIconPressed: _selectDate,
                  validator: _validateDateOfBirth,
                  onChanged: (value) =>
                      authProviderController.updateProfile(dateOfBirth: value),
                ),
                const SizedBox(height: 24),

                // Address Information Section
                const Text(
                  'Address Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Address
                CustomTextField(
                  label: 'Address',
                  labelText: 'Address ',
                  hintText: 'Address',
                  controller: _addressController,


                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 3,
                  onChanged: (value) =>
                      authProviderController.updateProfile(address: value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Submit button is anchored to bottom via bottomNavigationBar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Terms & Privacy with agreement checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 16),
                Consumer(
                  builder: (context, ref, _) {
                    return Checkbox(
                      value: isAgreedTerms,
                      activeColor: AppColors.darkGreen,
                      onChanged: (value) {
                        setState(() {
                          isAgreedTerms = value!;
                        });
                      },
                    );
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isAgreedTerms = !isAgreedTerms;
                      });
                    },
                    child: const Text(
                      'By continuing, you agree to our\nTerms & Privacy Policy',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 12, color: AppColors.black),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, _) {
                    final viewController = ref.watch(
                      authProvider.select((value) => value.isLoading),
                    );
                    return ElevatedButton(
                      onPressed: (viewController || !isAgreedTerms)
                          ? null
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        disabledBackgroundColor: Colors.grey[400],
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(34),
                        ),
                      ),
                      child: viewController
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isAtLeast21(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final years = difference.inDays ~/ 365;
    return years >= 21;
  }

  String? _validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }

    final dateRegex = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Please enter valid date (DD/MM/YYYY)';
    }

    try {
      final parts = value.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);

      if (!_isAtLeast21(date)) {
        return 'You must be at least 21 years old';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }

    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 21 * 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _dateOfBirthController.text = formattedDate;
      authProviderController.updateProfile(dateOfBirth: formattedDate);

      if (mounted) {
        _formKey.currentState?.validate();
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Update all form data in the provider

      final success = await authProviderController.updateUserProfile();

      if (mounted) {
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          CustomFloatingToast.showToast(
            'Failed to save profile. Please try again.',
          );
        }
      }
    }
  }
}
