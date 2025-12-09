import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/address_controller.dart';
import 'package:task_new/controllers/location_provider.dart';
import 'package:task_new/controllers/cart_controller.dart';
import 'package:task_new/controllers/verification_controller.dart';
import 'package:task_new/controllers/coupon_card_controller.dart';
import 'package:task_new/models/address_model.dart';
import 'package:task_new/screens/apply_coupon_card_screen.dart';
import 'package:task_new/screens/payment_success_screen.dart';
import 'package:task_new/services/razorpay_service.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/widgets/custom_textfield.dart';
import 'package:task_new/widgets/section_header.dart';
import 'package:task_new/widgets/verification_dialog.dart';
import 'package:task_new/widgets/custom_alert_dialogue.dart';
import 'package:task_new/widgets/discount_offer_card.dart';
import 'package:task_new/widgets/cart_summary_card.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String selectedDeliveryType = 'standard';
  String selectedPaymentMethod = 'cash_on_delivery';
  bool isProcessingOrder = false;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  RazorPayService? _razorPayService;

  @override
  void initState() {
    super.initState();
    
    // Initialize Razorpay service
_loadSavedAddress();
    _initializeRazorpay();
  }
void _loadSavedAddress() {
    final addressController = ref.read(addressProvider);
    final locationState = ref.read(locationProvider);
    
    if (addressController.address != null) {
      final savedAddress = addressController.address!;
      _addressController.text = savedAddress.fullAddress;
      _nameController.text = savedAddress.name;
      _emailController.text = savedAddress.email;
      _phoneController.text = savedAddress.phone;
      _instructionsController.text = savedAddress.deliveryInstructions ?? '';
    } else if (locationState.detailedAddress != null) {
      // Auto-populate from current location if no saved address
      final loc = locationState.detailedAddress!;
      final street = loc['street'] ?? '';
      final city = loc['city'] ?? '';
      final state = loc['state'] ?? '';
      final zip = loc['zip'] ?? '';
      final country = loc['country'] ?? 'India';
      _addressController.text = [street, city, state, zip, country].where((s) => s.isNotEmpty).join(', ');
    }
  }

  // void _selectCurrentLocation() {
  //   final locationState = ref.read(locationProvider);
  //   if (locationState.detailedAddress == null) return;
    
  //   final loc = locationState.detailedAddress!;
  //   setState(() {
  //     _nameController.text = '';
  //     _emailController.text = '';
  //     _phoneController.text = '';
  //     final street = loc['street'] ?? '';
  //     final city = loc['city'] ?? '';
  //     final state = loc['state'] ?? '';
  //     final zip = loc['zip'] ?? '';
  //     final country = loc['country'] ?? 'India';
  //     _addressController.text = [street, city, state, zip, country].where((s) => s.isNotEmpty).join(', ');
  //     _instructionsController.text = '';
  //   });
  // }

  void _selectCurrentLocation() {
  final locationState = ref.read(locationProvider);
  if (locationState.detailedAddress == null) return;
  
  final loc = locationState.detailedAddress!;
  
  // Get name from controller or use default
  final userName = _nameController.text.trim().isNotEmpty 
      ? _nameController.text.trim() 
      : 'Current Location';
  
  // Create a new address from location
  final locationAddress = AddressModel(
    name: userName,
    email: _emailController.text.trim(),
    phone: _phoneController.text.trim(),
    street: loc['street'] ?? '',
    apartment: '',
    city: loc['city'] ?? '',
    state: loc['state'] ?? '',
    zip: loc['zip'] ?? '',
    country: loc['country'] ?? 'India',
    deliveryInstructions: _instructionsController.text.trim(),
  );
  
  // Update address (this will check for duplicates)
  ref.read(addressProvider).updateAddress(locationAddress);
  
  setState(() {
    if (_nameController.text.isEmpty) _nameController.text = 'Current Location';
    final street = loc['street'] ?? '';
    final city = loc['city'] ?? '';
    final state = loc['state'] ?? '';
    final zip = loc['zip'] ?? '';
    final country = loc['country'] ?? 'India';
    _addressController.text = [street, city, state, zip, country]
        .where((s) => s.isNotEmpty)
        .join(', ');
    if (_instructionsController.text.isEmpty) {
      _instructionsController.text = 'Deliver to current location';
    }
  });
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Current location saved as address'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
}

  void _initializeRazorpay() {
    _razorPayService = RazorPayService(
      onPaymentSuccess: () async {
        final cartController = ref.read(cartProvider.notifier);
        await cartController.clearCart();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(
                orderId: 'TH${DateTime.now().millisecondsSinceEpoch}',
                amount: _getTotalAmount(),
              ),
            ),
          );
        }
      },
      onPaymentFailed: () {
        if (mounted) {
          setState(() {
            isProcessingOrder = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment failed, please try again"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      onPaymentClose: () {
        if (mounted) {
          setState(() {
            isProcessingOrder = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = ref.watch(cartProvider);
    final verificationService = ref.watch(verificationServiceProvider);
    final coupon = ref.watch(couponProvider);
    final subtotal = cartController.subtotal;
 final addressController = ref.watch(addressProvider);
    final deliveryFee = _getDeliveryFee();
    final totalBeforeDiscount = subtotal + deliveryFee;

    // Calculate verification discount
    final verificationDiscount =
        verificationService.isEligibleForDiscount(
          cartController.items,
          totalBeforeDiscount,
        )
        ? verificationService.calculateDiscount(totalBeforeDiscount)
        : 0.0;

    // Calculate final total with all discounts applied
    final total =
        totalBeforeDiscount - verificationDiscount - coupon.discountAmount;
//Sync controllers when address changes
    if (addressController.address != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final saved = addressController.address!;
        if (_addressController.text != saved.fullAddress) {
          _addressController.text = saved.fullAddress;
          _nameController.text = saved.name;
          _emailController.text = saved.email;
          _phoneController.text = saved.phone;
          _instructionsController.text = saved.deliveryInstructions ?? '';
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ApplyCouponCard(totalAmount: subtotal),
                  // Discount Offer Card
                  // DiscountOfferCard(
                  //   subtotal: subtotal,
                  //   deliveryFee: deliveryFee,
                  // ),

                  // Delivery Address Section
                  _buildSectionCard(
                    title: 'Delivery Address',
                    child: Column(
                      children: [
                        if (addressController.addresses.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: AppColors.darkGreen, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Saved Addresses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: _showAddressDialog,
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add New'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: addressController.addresses.length + 1,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (ctx, idx) {
                                    // Show current location as first option
                                    if (idx == 0) {
                                      final locationState = ref.watch(locationProvider);
                                      final hasLocationData = locationState.detailedAddress != null && locationState.detailedAddress!.isNotEmpty;
                                      
                                      if (hasLocationData) {
                                        return RadioListTile<String>(
                                          value: 'current_location',
                                          groupValue: addressController.address == null ? 'current_location' : null,
                                          title: const Text('Current Location'),
                                          subtitle: Text(
                                            '${locationState.detailedAddress!['street'] ?? ''}, ${locationState.detailedAddress!['city'] ?? ''}, ${locationState.detailedAddress!['state'] ?? ''} ${locationState.detailedAddress!['zip'] ?? ''}',
                                            style: TextStyle(color: Colors.grey[700]),
                                          ),
                                          onChanged: (v) {
                                            if (v == null) return;
                                            ref.read(addressProvider).clearAddress();
                                            _selectCurrentLocation();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Address selected'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
                                            );
                                          },
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }
                                    
                                    final actualIdx = idx - 1;
                                    final a = addressController.addresses[actualIdx];
                                    final selectedIndex = addressController.address != null
                                        ? addressController.addresses.indexWhere((x) => x.fullAddress == addressController.address!.fullAddress && x.name == addressController.address!.name)
                                        : -1;
                                    return RadioListTile<int>(
                                      value: actualIdx,
                                      groupValue: selectedIndex >= 0 && addressController.address != null ? selectedIndex : null,
                                      title: Text(a.name),
                                      subtitle: Text(a.fullAddress, style: TextStyle(color: Colors.grey[700])),
                                      onChanged: (v) {
                                        if (v == null) return;
                                        ref.read(addressProvider).selectAddress(v);
                                        final chosen = addressController.addresses[v];
                                        setState(() {
                                          _nameController.text = chosen.name;
                                          _emailController.text = chosen.email;
                                          _phoneController.text = chosen.phone;
                                          _addressController.text = chosen.fullAddress;
                                          _instructionsController.text = chosen.deliveryInstructions ?? '';
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Address selected'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Container(
                        //   padding: const EdgeInsets.all(16),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(color: Colors.grey[200]!),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       Container(
                        //         padding: const EdgeInsets.all(8),
                        //         decoration: BoxDecoration(
                        //           color: AppColors.lightBackground,
                        //           borderRadius: BorderRadius.circular(8),
                        //         ),
                        //         child: const Icon(
                        //           Icons.location_on,
                        //           color: AppColors.darkGreen,
                        //           size: 20,
                        //         ),
                        //       ),
                        //       const SizedBox(width: 12),
                        //       Expanded(
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             const Text(
                        //               'Home',
                        //               style: TextStyle(
                        //                 fontSize: 16,
                        //                 fontWeight: FontWeight.w600,
                        //               ),
                        //             ),
                        //             const SizedBox(height: 4),
                        //             Column(

                        //               children: [

                                    
                        //             Text(
                        //               addressController.address?.fullAddress ?? _addressController.text,
                        //               style: TextStyle(
                        //                 fontSize: 14,
                        //                 color: Colors.grey[600],
                        //               ),
                        //             ),
                        //             ],)
                        //           ],
                        //         ),
                        //       ),
                        //       TextButton(
                        //         onPressed: _showAddressDialog,
                        //         child: const Text(
                        //           'Change',
                        //           style: TextStyle(
                        //             color: AppColors.darkGreen,
                        //             fontWeight: FontWeight.w600,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Delivery Time Section
                  // _buildSectionCard(
                  //   title: 'Delivery Time',
                  //   child: Column(
                  //     children: [
                  //       _buildDeliveryOption(
                  //         'standard',
                  //         'Standard Delivery',
                  //         '2-3 days',
                  //         2.99,
                  //         Icons.schedule,
                  //       ),
                  //       const SizedBox(height: 12),
                  //       _buildDeliveryOption(
                  //         'express',
                  //         'Express Delivery',
                  //         'Tomorrow',
                  //         5.99,
                  //         Icons.flash_on,
                  //         isSelected: true,
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // const SizedBox(height: 20),

                  // Payment Method Section
                  _buildSectionCard(
                    title: 'Payment Method',
                    child: Column(
                      children: [
                        _buildPaymentOption(
                          'razorpay',
                          'Online Payment',
                          'Pay with Razorpay (Cards, UPI, Wallets)',
                          Icons.payment,
                        ),
                        // const SizedBox(height: 12),
                        // _buildPaymentOption(
                        //   'cash_on_delivery',
                        //   'Cash on Delivery',
                        //   'Pay when you receive',
                        //   Icons.money,
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Order Summary Section
                  CartSummaryCard(
                    subtotal: subtotal,
                    deliveryFee: deliveryFee,
                    total: total,
                  ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),

          // Bottom Checkout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessingOrder ? null : _handlePlaceOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessingOrder
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            selectedPaymentMethod == 'razorpay'
                                ? 'Pay ₹${total.toStringAsFixed(2)}'
                                : 'Place Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDeliveryOption(
    String value,
    String title,
    String subtitle,
    double price,
    IconData icon,
    Widget child, {
    bool isSelected = false,
  }) {
    final isCurrentSelected = selectedDeliveryType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDeliveryType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentSelected ? AppColors.darkGreen : Colors.grey[200]!,
            width: isCurrentSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentSelected
                    ? AppColors.darkGreen.withOpacity(0.1)
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isCurrentSelected
                    ? AppColors.darkGreen
                    : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCurrentSelected
                          ? AppColors.darkGreen
                          : AppColors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
            Text(
              '₹${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrentSelected
                    ? AppColors.darkGreen
                    : AppColors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    String subtitle,
    IconData icon, {
    bool isSelected = false,
  }) {
    final isCurrentSelected = selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        debugPrint('Payment method selected: $value');
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentSelected ? AppColors.darkGreen : Colors.grey[200]!,
            width: isCurrentSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentSelected
                    ? AppColors.darkGreen.withOpacity(0.1)
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isCurrentSelected
                    ? AppColors.darkGreen
                    : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCurrentSelected
                          ? AppColors.darkGreen
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal
                ? Colors.black87
                : (isDiscount ? Colors.green[700] : Colors.grey[600]),
          ),
        ),
        Text(
          '₹${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal
                ? AppColors.darkGreen
                : (isDiscount ? Colors.green[700] : Colors.black87),
          ),
        ),
      ],
    );
  }

  double _getDeliveryFee() {
    switch (selectedDeliveryType) {
      case 'standard':
        return 2.99;
      case 'express':
        return 5.99;
      default:
        return 2.99;
    }
  }

  void _showAddressDialog() {
    final locationState = ref.read(locationProvider);
    final locationData = locationState.detailedAddress ?? {};

    final _dialogFormKey = GlobalKey<FormState>();

    // Controllers pre-filled from location data for new address
    final nameCtrl = TextEditingController(text: _nameController.text);
    final emailCtrl = TextEditingController(text: _emailController.text);
    final phoneCtrl = TextEditingController(text: _phoneController.text);
    final streetCtrl = TextEditingController(text: 
   // locationData['street'] ??
     '');
    final apartmentCtrl = TextEditingController(text: '');
    final cityCtrl = TextEditingController(text:
   //  locationData['city'] ?? 
     '');
    final stateCtrl = TextEditingController(text: 
   // locationData['state'] ??
     '');
    final zipCtrl = TextEditingController(text: 
   // locationData['zip'] ??
     '');
    final countryCtrl = TextEditingController(text: 
    //locationData['country'] ??
     'India');
    final instructionsCtrl = TextEditingController(text: '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
                maxWidth: MediaQuery.of(context).size.width * 0.95,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
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
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add New Address',
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Always show the address form
                          // Shipping Address Form
                            SectionHeader(
                              icon: Icons.home_outlined,
                              title: 'Shipping Address',
                              subtitle: 'Where should we deliver?',
                            ),
                            const SizedBox(height: 16),
                            Form(
                              key: _dialogFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    label: 'Street Address',
                                    controller: streetCtrl,
                                    hintText: '123 Main Street',
                                    prefixIcon: Icons.location_on_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter street address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  CustomTextField(
                                    label: 'Apartment, Suite, etc.',
                                    controller: apartmentCtrl,
                                    hintText: 'Plot No. / Apartment',
                                    prefixIcon: Icons.apartment_outlined,
                                    isOptional: true,
                                    validator: (value) => null,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          label: 'City',
                                          controller: cityCtrl,
                                          hintText: 'Your City',
                                          prefixIcon: Icons.location_city,
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
                                          label: 'State',
                                          controller: stateCtrl,
                                          hintText: 'State',
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
                                          label: 'ZIP Code',
                                          controller: zipCtrl,
                                          hintText: '110001',
                                          prefixIcon: Icons.mail_outline,
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
                                          label: 'Country',
                                          controller: countryCtrl,
                                          hintText: 'India',
                                          prefixIcon: Icons.public,
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
                                  const SizedBox(height: 24),
                                  SectionHeader(
                                    icon: Icons.note_outlined,
                                    title: 'Delivery Instructions',
                                    subtitle: 'Optional but helpful',
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[50],
                                    ),
                                    child: TextField(
                                      controller: instructionsCtrl,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: 'E.g., Ring doorbell twice, Leave at gate, etc.',
                                        hintStyle: TextStyle(color: Colors.grey[400]),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                        ],
                      ),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
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
                              // Validate and save new address
                              if (_dialogFormKey.currentState!.validate()) {
                                final newAddress = AddressModel(
                                  name: nameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  street: streetCtrl.text.trim(),
                                  apartment: apartmentCtrl.text.trim(),
                                  city: cityCtrl.text.trim(),
                                  state: stateCtrl.text.trim(),
                                  zip: zipCtrl.text.trim(),
                                  country: countryCtrl.text.trim(),
                                  deliveryInstructions: instructionsCtrl.text.trim(),
                                );
                                ref.read(addressProvider).updateAddress(newAddress);
                                // update the quick display fields in checkout
                                setState(() {
                                  _nameController.text = nameCtrl.text.trim();
                                  _emailController.text = emailCtrl.text.trim();
                                  _phoneController.text = phoneCtrl.text.trim();
                                  _addressController.text = [
                                    streetCtrl.text.trim(),
                                    apartmentCtrl.text.trim(),
                                    cityCtrl.text.trim(),
                                    stateCtrl.text.trim(),
                                    zipCtrl.text.trim(),
                                    countryCtrl.text.trim(),
                                  ].where((s) => s.isNotEmpty).join(', ');
                                  _instructionsController.text = instructionsCtrl.text.trim();
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Address saved successfully!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
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
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
    @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _razorPayService?.dispose();
    super.dispose();
  }

          // ElevatedButton(
          //   onPressed: () {
          //     setState(() {});
          //     Navigator.pop(ctx);
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: AppColors.darkGreen,
          //   ),
          //   child: const Text('Save', style: TextStyle(color: Colors.white)),
          // ),
            // })
        // ],
    //   ),
    // );
  // }

  void _handlePlaceOrder() {
    debugPrint('Selected payment method: $selectedPaymentMethod');

    if (selectedPaymentMethod == 'razorpay') {
      debugPrint('Processing Razorpay payment...');
      _processRazorpayPayment();
    } else {
      debugPrint('Processing Cash on Delivery order...');
      _placeCashOnDeliveryOrder();
    }
  }

  void _processRazorpayPayment() {
    setState(() {
      isProcessingOrder = true;
    });

    final total = _getTotalAmount();
    debugPrint('Opening Razorpay with amount: ₹$total');

    _razorPayService?.openPayment(
      amount: total,
      customerName: _nameController.text.trim(),
      customerEmail: _emailController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      description: 'True Harvest - Fresh Organic Products',
    );
  }

  Future<void> _placeCashOnDeliveryOrder() async {
    setState(() {
      isProcessingOrder = true;
    });

    // Simulate order processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isProcessingOrder = false;
    });

    if (!mounted) return;

    // Clear cart
    ref.read(cartProvider.notifier).clearCart();

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomAlertDialog(
        title: "Order Placed Successfully!",
        message:
            "Your order has been placed successfully. You will receive a confirmation shortly.",
        confirmText: "Continue Shopping",
        onConfirm: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  double _getTotalAmount() {
    final cartController = ref.read(cartProvider);
    final verificationService = ref.read(verificationServiceProvider);
    final coupon = ref.read(couponProvider);
    final subtotal = cartController.subtotal;
    final deliveryFee = _getDeliveryFee();
    final totalBeforeDiscount = subtotal + deliveryFee;

    // Calculate verification discount
    final verificationDiscount =
        verificationService.isEligibleForDiscount(
          cartController.items,
          totalBeforeDiscount,
        )
        ? verificationService.calculateDiscount(totalBeforeDiscount)
        : 0.0;

    // Calculate final total with all discounts applied
    final double finalTotal =
        totalBeforeDiscount - verificationDiscount - coupon.discountAmount;

    return finalTotal > 0 ? finalTotal : 0.0; // Ensure total is never negative
  }

  Widget _buildVerificationBanner(verificationService, double discountAmount) {
    if (verificationService.isVerified && discountAmount > 0) {
      // Show success banner for verified users with discount
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.verified_user,
                color: Colors.green[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎉 Animal Kart Discount Applied!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                  Text(
                    'You saved ₹${discountAmount.toStringAsFixed(2)} on this order',
                    style: TextStyle(fontSize: 14, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (!verificationService.isVerified) {
      // Show verification offer banner
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkGreen.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_offer,
                color: AppColors.darkGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animal Kart User? Get 10% OFF!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const Text(
                    'Verify your account for instant discount',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _showVerificationDialog(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Verify'),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => const VerificationDialog(),
    );
  }
}