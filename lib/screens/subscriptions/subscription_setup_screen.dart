import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_new/controllers/location_provider.dart';
import 'package:task_new/controllers/subscription_controller.dart';
import 'package:task_new/controllers/address_controller.dart';
import 'package:task_new/controllers/address_form_controller.dart';
import 'package:task_new/models/advanced_subscription_model.dart';
import 'package:task_new/models/product_model.dart';
import 'package:task_new/models/address_model.dart';
import 'package:task_new/models/address_form_state.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/screens/subscriptions/subscription_checkout_screen.dart';
import 'package:task_new/widgets/address_form_fields.dart';

class SubscriptionSetupScreen extends ConsumerStatefulWidget {
  final Product product;
  final String selectedUnit;
  final SubscriptionPlanTemplate selectedPlan;

  const SubscriptionSetupScreen({
    Key? key,
    required this.product,
    required this.selectedUnit,
    required this.selectedPlan,
  }) : super(key: key);

  @override
  ConsumerState<SubscriptionSetupScreen> createState() =>
      _SubscriptionSetupScreenState();
}

class _SubscriptionSetupScreenState
    extends ConsumerState<SubscriptionSetupScreen> {
  DeliveryPattern selectedPattern = DeliveryPattern.daily;
  DateTime startDate = DateTime.now().add(const Duration(days: 1));
  int defaultQuantity = 1;
  List<String> selectedWeeklyDays = [];
  List<CustomDeliveryDate> customDates = [];

  @override
  void initState() {
    super.initState();
    // Set default pattern based on plan type
    switch (widget.selectedPlan.planType) {
      case PlanType.daily:
        selectedPattern = DeliveryPattern.daily;
        break;
      case PlanType.alternateDay:
        selectedPattern = DeliveryPattern.alternate;
        break;
      case PlanType.weekly:
        selectedPattern = DeliveryPattern.weekly;
        selectedWeeklyDays = ['Mon', 'Wed', 'Fri'];
        break;
      default:
        selectedPattern = DeliveryPattern.daily;
    }
    _loadAddressData();
  }

  void _loadAddressData() {
    final addressController = ref.read(addressProvider);
    final locationState = ref.read(locationProvider);
    final formCtrl = ref.read(addressFormProvider);

    if (addressController.address != null) {
      formCtrl.loadAddress(addressController.address!);
    } else if (locationState.detailedAddress != null) {
      formCtrl.loadFromLocation(locationState.detailedAddress!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Setup Subscription'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Summary
                  _buildPlanSummary(),
                  const SizedBox(height: 20),

                  // Delivery Pattern Selection
                  // _buildDeliveryPatternSection(),
                  // const SizedBox(height: 20),

                  // Start Date Selection
                  _buildStartDateSection(),
                  const SizedBox(height: 20),

                  // Quantity Selection
                  _buildQuantitySection(),
                  const SizedBox(height: 20),

                  // Weekly Days Selection (if weekly pattern)
                  if (selectedPattern == DeliveryPattern.weekly)
                    _buildWeeklyDaysSection(),

                  // Custom Dates (if custom pattern)
                  if (selectedPattern == DeliveryPattern.custom)
                    _buildCustomDatesSection(),

                  const SizedBox(height: 20),

                  // Delivery Address
                  _buildDeliveryAddressSection(),
                  const SizedBox(height: 20),

                  // Price Summary
                  _buildPriceSummary(),
                ],
              ),
            ),
          ),

          // Continue Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continueToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  widget.product.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.selectedUnit} • ${widget.selectedPlan.name}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer, color: AppColors.darkGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${widget.selectedPlan.discountPercentage.toStringAsFixed(0)}% discount on ${widget.selectedPlan.durationInDays} days plan',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildDeliveryPatternSection() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Delivery Pattern',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         ...DeliveryPattern.values.map((pattern) {
  //           final isSelected = selectedPattern == pattern;
  //           return Container(
  //             margin: const EdgeInsets.only(bottom: 8),
  //             child: InkWell(
  //               onTap: () => setState(() => selectedPattern = pattern),
  //               borderRadius: BorderRadius.circular(8),
  //               child: Container(
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     color: isSelected ? AppColors.darkGreen : Colors.grey[300]!,
  //                   ),
  //                   borderRadius: BorderRadius.circular(8),
  //                   color: isSelected ? AppColors.darkGreen.withOpacity(0.1) : null,
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Radio<DeliveryPattern>(
  //                       value: pattern,
  //                       groupValue: selectedPattern,
  //                       onChanged: (value) => setState(() => selectedPattern = value!),
  //                       activeColor: AppColors.darkGreen,
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             _getPatternTitle(pattern),
  //                             style: const TextStyle(
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.w600,
  //                             ),
  //                           ),
  //                           Text(
  //                             _getPatternDescription(pattern),
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               color: Colors.grey[600],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         }),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStartDateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start Date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectStartDate,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.darkGreen),
                  const SizedBox(width: 12),
                  Text(
                    '${startDate.day}/${startDate.month}/${startDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantity per Delivery',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: defaultQuantity > 1
                    ? () => setState(() => defaultQuantity--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.darkGreen,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  defaultQuantity.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => defaultQuantity++),
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.darkGreen,
              ),
              const SizedBox(width: 12),
              Text(
                widget.selectedUnit,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDaysSection() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Delivery Days',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weekDays.map((day) {
              final isSelected = selectedWeeklyDays.contains(day);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedWeeklyDays.remove(day);
                    } else {
                      selectedWeeklyDays.add(day);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.darkGreen : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    day,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDatesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Custom Delivery Dates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addCustomDate,
                icon: const Icon(Icons.add),
                label: const Text('Add Date'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (customDates.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text(
                  'No custom dates added yet.\nTap "Add Date" to create your schedule.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...customDates.map(
              (customDate) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.darkGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${customDate.date.day}/${customDate.date.month}/${customDate.date.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      '${customDate.quantity} ${widget.selectedUnit}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    IconButton(
                      onPressed: () => _removeCustomDate(customDate),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressSection() {
    return Consumer(
      builder: (context, ref, child) {
        final addressController = ref.watch(addressProvider);
        final savedAddress = addressController.address;
        final locationaddress=ref.watch(locationProvider);
        final isUsingLocation=addressController.address==null && locationaddress.detailedAddress!=null;
        final locationdata=locationaddress.detailedAddress;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     // Allow user to edit address in _addressController
                  //     _showAddressEditDialog({});
                  //   },
                  //   child: const Text('Edit'),
                  // ),
                ],
              ),
              const SizedBox(height: 12),
              if (savedAddress != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.darkGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Complete Address as paragraph
                      Text(
                        //'${savedAddress.name}, ${savedAddress.phone}, ${savedAddress.email}, 
                        '${savedAddress.street}, ${savedAddress.apartment}, ${savedAddress.city}, ${savedAddress.state} ${savedAddress.zip}, ${savedAddress.country}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                      if (savedAddress.deliveryInstructions != null &&
                          savedAddress.deliveryInstructions!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.amber[800],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
  text: TextSpan(
    style: const TextStyle(
      fontSize: 13,
      color: Colors.black,
    ),
    children: [
      const TextSpan(
        text: 'Instructions: ',
      ),
      TextSpan(
        text: savedAddress.deliveryInstructions,
        style: const TextStyle(
          fontWeight: FontWeight.bold,   
          color: Colors.black,          
        ),
      ),
    ],
  ),
)

                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else if (isUsingLocation && locationdata != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Address from current location',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          // TextButton(
                          //   onPressed: () {
                          //     _showAddressEditDialog(locationdata);
                          //   },
                          //   child: const Text('Edit'),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Address in paragraph format
                      Text(
                        '${locationdata.street}, ${locationdata.city}, ${locationdata.state} ${locationdata.zip}, ${locationdata.country}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No saved address found.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please add a delivery address in your profile to proceed.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                      // const SizedBox(height: 12),
                      // ElevatedButton.icon(
                      //   onPressed: () {
                      //     _showAddressEditDialog();
                      //   },
                      //   icon: const Icon(Icons.add),
                      //   label: const Text('Add Address'),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: AppColors.darkGreen,
                      //     foregroundColor: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddressEditDialog(AddressFormState? locationdata) {
    // Initialize form controller with location data
    if (locationdata != null) {
      final formCtrl = ref.read(addressFormProvider);
      formCtrl.loadAddress(AddressModel(
        id: '',
        name: locationdata.name,
        email: locationdata.email,
        phone: locationdata.phone,
        street: locationdata.street,
        apartment: locationdata.apartment,
        city: locationdata.city,
        state: locationdata.state,
        zip: locationdata.zip,
        country: locationdata.country,
        deliveryInstructions: locationdata.instructions.isEmpty ? null : locationdata.instructions,
      ));
    }

    final _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
            maxWidth: MediaQuery.of(ctx).size.width * 0.95,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Address',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Enter your delivery address',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Consumer(builder: (ctx, ref2, _) {
                    return AddressFormFields(
                      includePersonalInfo: false,
                      formKey: _dialogFormKey,
                    );
                  }),
                ),
              ),
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Consumer(builder: (ctx, ref2, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_dialogFormKey.currentState!.validate()) {
                              final address = ref2.read(addressFormProvider).buildAddressModel();
                              ref2.read(addressProvider).addAddress(address);
                              Navigator.pop(ctx);
                              Fluttertoast.showToast(
                                msg: "Address saved successfully",
                                backgroundColor: AppColors.darkGreen,
                                textColor: AppColors.white,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                            
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Save Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    final totalPrice = _calculateTotalPrice();
    final originalPrice = _calculateOriginalPrice();
    final savings = originalPrice - totalPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Original Price'),
              Text('₹${originalPrice.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discount (${widget.selectedPlan.discountPercentage.toStringAsFixed(0)}%)',
                style: TextStyle(color: Colors.green[700]),
              ),
              Text(
                '-₹${savings.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.green[700]),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  double _calculateTotalPrice() {
    final service = ref.read(advancedSubscriptionServiceProvider);
    final endDate = startDate.add(
      Duration(days: widget.selectedPlan.durationInDays),
    );

    return service.calculateSubscriptionPrice(
      product: widget.product,
      unit: widget.selectedUnit,
      planType: widget.selectedPlan.planType,
      deliveryPattern: selectedPattern,
      startDate: startDate,
      endDate: endDate,
      defaultQty: defaultQuantity,
      weeklyDays: selectedWeeklyDays,
      customDates: customDates,
    );
  }

  double _calculateOriginalPrice() {
    final totalPrice = _calculateTotalPrice();
    return totalPrice / (1 - widget.selectedPlan.discountPercentage / 100);
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != startDate) {
      setState(() => startDate = picked);
    }
  }

  void _addCustomDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: startDate.add(
        Duration(days: widget.selectedPlan.durationInDays),
      ),
    );

    if (pickedDate != null) {
      // Show quantity dialog
      final int? quantity = await _showQuantityDialog();
      if (quantity != null) {
        setState(() {
          customDates.add(
            CustomDeliveryDate(date: pickedDate, quantity: quantity),
          );
          customDates.sort((a, b) => a.date.compareTo(b.date));
        });
      }
    }
  }

  void _removeCustomDate(CustomDeliveryDate customDate) {
    setState(() {
      customDates.remove(customDate);
    });
  }

  Future<int?> _showQuantityDialog() async {
    int quantity = 1;
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Quantity'),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () => setState(() => quantity--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, quantity),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _continueToCheckout() {
    // Check if we have a valid address from either source
    final addrCtrl = ref.read(addressProvider);
    final savedAddress = addrCtrl.address;
    final locationaddress = ref.read(locationProvider);
    final isUsingLocation =
      addrCtrl.address == null && locationaddress.detailedAddress != null;
    final locationdata = locationaddress.detailedAddress;

    // Build address string - prefer saved address, then location data, then manual entry
    String deliveryAddress = '';
    if (savedAddress != null) {
      deliveryAddress = [
        savedAddress.street,
        savedAddress.apartment,
        savedAddress.city,
        savedAddress.state,
        savedAddress.zip,
        savedAddress.country,
      ].where((s) => s.isNotEmpty).join(', ');
    } else if (isUsingLocation && locationdata != null) {
      deliveryAddress = locationdata.fullAddress.isEmpty 
          ? [
              locationdata.street,
              locationdata.city,
              locationdata.state,
              locationdata.zip,
              locationdata.country,
            ].where((s) => s.isNotEmpty).join(', ')
          : locationdata.fullAddress;
    } else {
      // Try to get address from form controller
      final formCtrl = ref.read(addressFormProvider);
      if (formCtrl.fullAddress.isNotEmpty) {
        deliveryAddress = formCtrl.fullAddress;
      }
    }

    // Validate that we have an address
    if (deliveryAddress.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Please enter delivery address'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      Fluttertoast.showToast(
        msg: "Please enter delivery address",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (selectedPattern == DeliveryPattern.weekly &&
        selectedWeeklyDays.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Please select at least one delivery day'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      Fluttertoast.showToast(
        msg: "Please select at least one delivery day",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (selectedPattern == DeliveryPattern.custom && customDates.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Please add at least one custom delivery date'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      Fluttertoast.showToast(
        msg: "Please add at least one custom delivery date",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionCheckoutScreen(
          product: widget.product,
          selectedUnit: widget.selectedUnit,
          selectedPlan: widget.selectedPlan,
          deliveryPattern: selectedPattern,
          startDate: startDate,
          defaultQuantity: defaultQuantity,
          weeklyDays: selectedWeeklyDays,
          customDates: customDates,
          deliveryAddress: deliveryAddress,
          deliveryInstructions: ref.read(addressFormProvider).instructions,
        ),
      ),
    );
  }
}
