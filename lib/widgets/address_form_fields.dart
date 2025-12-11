import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/address_controller.dart';
import 'package:task_new/models/address_model.dart';
import 'package:task_new/widgets/custom_textfield.dart';

class AddressFormFields extends ConsumerStatefulWidget {
  final bool includePersonalInfo;
  final bool includeInstructions;
  final bool includeDeliveryInstructions;
  final GlobalKey<FormState>? formKey;

  const AddressFormFields({
    Key? key,
    this.includePersonalInfo = true,
    this.includeInstructions = true,
    this.includeDeliveryInstructions = true,
    this.formKey,
  }) : super(key: key);

  @override
  ConsumerState<AddressFormFields> createState() => _AddressFormFieldsState();
}

class _AddressFormFieldsState extends ConsumerState<AddressFormFields> {
  late final TextEditingController _nameController;
  // late final TextEditingController _emailController;
  // late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipController;
  late final TextEditingController _countryController;
  late final TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    final addressControllerProvider = ref.read(addressProvider);
    final currentAddress = addressControllerProvider.address;

    _nameController = TextEditingController(text: currentAddress?.name ?? '');

    _streetController = TextEditingController(text: currentAddress?.street ?? '');
    _cityController = TextEditingController(text: currentAddress?.city ?? '');
    _stateController = TextEditingController(text: currentAddress?.state ?? '');
    _zipController = TextEditingController(text: currentAddress?.zip ?? '');
    _countryController = TextEditingController(text: currentAddress?.country ?? 'India');
    _instructionsController = TextEditingController(
      text: currentAddress?.deliveryInstructions ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    // _emailController.dispose();
    // _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _updateAddress() {
    final addressCtrl = ref.read(addressProvider);
    final currentAddress = addressCtrl.address ??  AddressModel(
      id: '0',
      name: '',
     
      street: '',
      city: '',
      state: '',
      zip: '',
      country: 'India',
    );

    final updatedAddress = currentAddress.copyWith(
      name: _nameController.text,
     
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      zip: _zipController.text,
      country: _countryController.text,
      deliveryInstructions: _instructionsController.text.isNotEmpty 
          ? _instructionsController.text 
          : null,
    );

    // Update the address in the provider
    if (currentAddress.id == '0') {
      addressCtrl.addAddress(updatedAddress);
    } else {
      addressCtrl.updateAddress(updatedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      onChanged: _updateAddress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.includePersonalInfo) ...[
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // CustomTextField(
            //   controller: _emailController,
            //   label: 'Email',
            //   hintText: 'Enter your email',
            //   prefixIcon: Icons.email_outlined,
            //   keyboardType: TextInputType.emailAddress,
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please enter your email';
            //     }
            //     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            //       return 'Please enter a valid email';
            //     }
            //     return null;
            //   },
            // ),
            const SizedBox(height: 12),
            // CustomTextField(
            //   controller: _phoneController,
            //   label: 'Phone Number',
            //   hintText: 'Enter your phone number',
            //   prefixIcon: Icons.phone_outlined,
            //   keyboardType: TextInputType.phone,
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please enter your phone number';
            //     }
            //     if (value.length < 10) {
            //       return 'Please enter a valid phone number';
            //     }
            //     return null;
            //   },
            // ),
            const SizedBox(height: 16),
            const Text(
              'Address Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          CustomTextField(
            controller: _streetController,
            label: 'Street Address',
            hintText: 'House/Flat No, Building, Street',
            prefixIcon: Icons.home_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your street address';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          // CustomTextField(
          //   controller: _apartmentController,
          //   label: 'Apartment, Suite, etc. (Optional)',
          //   hintText: 'Apartment, suite, unit, building, floor, etc.',
          //   prefixIcon: Icons.apartment_outlined,
          // ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _cityController,
                  label: 'City',
                  hintText: 'Enter city',
                  prefixIcon: Icons.location_city_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _stateController,
                  label: 'State/Province',
                  hintText: 'Enter state',
                  prefixIcon: Icons.map_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _zipController,
                  label: 'ZIP/Postal Code',
                  hintText: 'Enter ZIP code',
                  prefixIcon: Icons.local_post_office_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _countryController,
                  label: 'Country',
                  hintText: 'Enter country',
                  prefixIcon: Icons.flag_outlined,
                  readOnly: true, // Can be made editable if needed
                ),
              ),
            ],
          ),
          if (widget.includeDeliveryInstructions) ...[
            const SizedBox(height: 12),
            CustomTextField(
              controller: _instructionsController,
              label: 'Delivery Instructions (Optional)',
              hintText: 'Gate code, building access, etc.',
              prefixIcon: Icons.note_add_outlined,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }
}