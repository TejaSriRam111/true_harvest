import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/address_controller.dart';
import 'package:task_new/controllers/location_provider.dart';
import 'package:task_new/controllers/whishlist_provider.dart';
import 'package:task_new/models/address_model.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/routes/app_routes.dart';
import 'package:task_new/controllers/verification_controller.dart';
import 'package:task_new/widgets/custom_textfield.dart';
import 'package:task_new/widgets/section_header.dart';
import 'package:task_new/widgets/verification_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

   final TextEditingController PhoneController = TextEditingController();

  final TextEditingController StreetController = TextEditingController();

   final TextEditingController ApartmentController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

   final TextEditingController stateController = TextEditingController();

  final TextEditingController ZIPController = TextEditingController();

   final TextEditingController countryController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Widget _buildSavedAddressesPanel() {
    final addrCtrl = ref.watch(addressProvider);
    final savedList = addrCtrl.addresses;
    final locationState = ref.watch(locationProvider);
    final hasLocationData = locationState.detailedAddress != null && locationState.detailedAddress!.isNotEmpty;
    
    final selectedIndex = addrCtrl.address != null
        ? addrCtrl.addresses.indexWhere((a) => a.fullAddress == addrCtrl.address!.fullAddress && a.name == addrCtrl.address!.name)
        : -1;

    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 8),
              const Text('Saved Addresses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddressesDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (savedList.isEmpty && !hasLocationData)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                'No saved addresses. Add one to quickly select during checkout.',
                style: TextStyle(color: Colors.grey[700]),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: savedList.length + (hasLocationData ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                // If we have location data and this is the last item, show current location
                if (hasLocationData && idx == savedList.length) {
                  return RadioListTile<String>(
                    value: 'current_location',
                    groupValue: addrCtrl.address == null ? 'current_location' : null,
                    title: const Text('Current Location'),
                    subtitle: Text(
                      '${locationState.detailedAddress!['street'] ?? ''}, ${locationState.detailedAddress!['city'] ?? ''}, ${locationState.detailedAddress!['state'] ?? ''} ${locationState.detailedAddress!['zip'] ?? ''}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    onChanged: (v) {
                      if (v == null) return;
                      // Clear provider selection to indicate current location is selected
                      ref.read(addressProvider).clearAddress();
                      // Populate controllers with current location data
                      final loc = locationState.detailedAddress!;
                      setState(() {
                        nameController.text = '';
                        emailController.text = '';
                        PhoneController.text = '';
                        StreetController.text = loc['street'] ?? '';
                        ApartmentController.text = '';
                        cityController.text = loc['city'] ?? '';
                        stateController.text = loc['state'] ?? '';
                        ZIPController.text = loc['zip'] ?? '';
                        countryController.text = loc['country'] ?? 'India';
                        instructionsController.text = '';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Current location selected'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
                      );
                    },
                  );
                }

                // Otherwise show saved address
                final a = savedList[idx];
                return RadioListTile<int>(
                  value: idx,
                  groupValue: selectedIndex >= 0 && addrCtrl.address != null ? selectedIndex : null,
                  title: Text(a.name),
                  subtitle: Text(a.fullAddress, style: TextStyle(color: Colors.grey[700])),
                  onChanged: (v) {
                    if (v == null) return;
                    // select the address in provider
                    ref.read(addressProvider).selectAddress(v);
                    final chosen = savedList[v];
                    setState(() {
                      nameController.text = chosen.name;
                      emailController.text = chosen.email;
                      PhoneController.text = chosen.phone;
                      StreetController.text = chosen.street;
                      ApartmentController.text = chosen.apartment;
                      cityController.text = chosen.city;
                      stateController.text = chosen.state;
                      ZIPController.text = chosen.zip;
                      countryController.text = chosen.country;
                      instructionsController.text = chosen.deliveryInstructions ?? '';
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
    );
  }

  // void _loadSavedAddress() {
  //   final addressController = ref.read(addressProvider);
  //   final locationState = ref.read(locationProvider);
    
  //   if (addressController.address != null) {
  //     final savedAddress = addressController.address!;
  //     nameController.text = savedAddress.name;
  //     emailController.text = savedAddress.email;
  //     PhoneController.text = savedAddress.phone;
  //     StreetController.text = savedAddress.street;
  //     ApartmentController.text = savedAddress.apartment;
  //     cityController.text = savedAddress.city;
  //     stateController.text = savedAddress.state;
  //     ZIPController.text = savedAddress.zip;
  //     countryController.text = savedAddress.country;
  //     instructionsController.text = savedAddress.deliveryInstructions ?? '';
  //   } else if (locationState.detailedAddress != null) {
  //     // Auto-populate from current location if no saved address
  //     final loc = locationState.detailedAddress!;
  //     final street = loc['street'] ?? '';
  //     final city = loc['city'] ?? '';
  //     final state = loc['state'] ?? '';
  //     final zip = loc['zip'] ?? '';
  //     final country = loc['country'] ?? 'India';
      
  //     StreetController.text = street;
  //     cityController.text = city;
  //     stateController.text = state;
  //     ZIPController.text = zip;
  //     countryController.text = country;
  //   }
  // }

  void _loadSavedAddress() {
  final addressController = ref.read(addressProvider);
  final locationState = ref.read(locationProvider);
  
  // This will now load from SharedPreferences
  if (addressController.address != null) {
    final savedAddress = addressController.address!;
    nameController.text = savedAddress.name;
    emailController.text = savedAddress.email;
    PhoneController.text = savedAddress.phone;
    StreetController.text = savedAddress.street;
    ApartmentController.text = savedAddress.apartment;
    cityController.text = savedAddress.city;
    stateController.text = savedAddress.state;
    ZIPController.text = savedAddress.zip;
    countryController.text = savedAddress.country;
    instructionsController.text = savedAddress.deliveryInstructions ?? '';
  } else if (locationState.detailedAddress != null) {
    // Auto-populate from current location if no saved address
    final loc = locationState.detailedAddress!;
    final street = loc['street'] ?? '';
    final city = loc['city'] ?? '';
    final state = loc['state'] ?? '';
    final zip = loc['zip'] ?? '';
    final country = loc['country'] ?? 'India';
    
    StreetController.text = street;
    cityController.text = city;
    stateController.text = state;
    ZIPController.text = zip;
    countryController.text = country;
  }
}

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadSavedAddress();
  }
  @override
  Widget build(BuildContext context) {
    final addressController = ref.watch(addressProvider);
    
    // Sync controllers when address changes
    if (addressController.address != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final saved = addressController.address!;
        if (nameController.text != saved.name) {
          nameController.text = saved.name;
          emailController.text = saved.email;
          PhoneController.text = saved.phone;
          StreetController.text = saved.street;
          ApartmentController.text = saved.apartment;
          cityController.text = saved.city;
          stateController.text = saved.state;
          ZIPController.text = saved.zip;
          countryController.text = saved.country;
          instructionsController.text = saved.deliveryInstructions ?? '';
        }
      });
    }
    
   // final addressSubtitle = addressController.addressSummary; 
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(),
            const SizedBox(height: 24),

            // Saved Addresses panel (radio buttons shown on the main screen)
            _buildSavedAddressesPanel(),
            const SizedBox(height: 24),

            // Menu Options
            _buildMenuSection('Account', [
             // _buildMenuItem(
              //   icon: Icons.person_outline,
              //   title: 'Personal Information',
              //   subtitle: 'Update your details',
              //   onTap: () => _showPersonalInfoDialog(),
              // ),
              // _buildMenuItem(
              //   icon: Icons.location_on_outlined,
              //   title: 'Addresses',
              //   subtitle: 'Manage delivery addresses',
              //   onTap: () => _showAddressesDialog(),
              // ),
              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                subtitle: 'Manage payment options',
                onTap: () => _showPaymentMethodsDialog(),
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection('Orders & Subscriptions', [
              _buildMenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Order History',
                subtitle: 'View past orders',
                onTap: () => _showOrderHistory(),
              ),
              _buildMenuItem(
                icon: Icons.subscriptions_outlined,
                title: 'My Subscriptions',
                subtitle: 'Manage subscriptions',
                onTap: () =>
                    AppRoutes.navigateTo(context, '/subscription-management'),
              ),
              _buildMenuItem(
                icon: Icons.favorite_outline,
                title: 'Wishlist',
                subtitle: 'Saved items',
                onTap: () => AppRoutes.navigateTo(context, '/wishlist'),
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection('Support & Settings', [
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact us',
                onTap: () => _showHelpDialog(),
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notifications',
                onTap: () => _showNotificationSettings(),
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () => _showPrivacyPolicy(),
              ),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and info',
                onTap: () => _showAboutDialog(),
              ),
            ]),

            const SizedBox(height: 24),

            // Logout Button
            _buildLogoutButton(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final verificationService = ref.watch(verificationServiceProvider);
    final userProfile = verificationService.userProfile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Icons.person, size: 40, color: AppColors.darkGreen),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userProfile?.name ?? 'uma',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (verificationService.isVerified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile?.email ?? 'uma.e@example.com',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile?.mobile ?? '+91 6305447441',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                if (!verificationService.isVerified) ...[
                  const SizedBox(height: 8),
                  // GestureDetector(
                  //   onTap: () => _showVerificationDialog(),
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 12,
                  //       vertical: 6,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: AppColors.darkGreen.withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(16),
                  //       border: Border.all(
                  //         color: AppColors.darkGreen.withOpacity(0.3),
                  //       ),
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Icon(
                  //           Icons.local_offer,
                  //           size: 14,
                  //           color: AppColors.darkGreen,
                  //         ),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           'Verify for 10% discount',
                  //           style: TextStyle(
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.w600,
                  //             color: AppColors.darkGreen,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ],
            ),
          ),
          // Edit Button
          IconButton(
            onPressed: () => _showPersonalInfoDialog(),
            icon: Icon(Icons.edit_outlined, color: AppColors.darkGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.shopping_bag_outlined,
            title: 'Orders',
            value: '12',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.subscriptions_outlined,
            title: 'Subscriptions',
            value: '3',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final wishlistcount=ref.watch(wishlistProvider).wishlistItems.length;
            
           return _buildStatCard(
              icon: Icons.favorite_outlined,
              title: 'Wishlist',
              value: wishlistcount.toString(),
              color: Colors.red,
            );
            }
          ),
        ), 
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
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
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.darkGreen, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red[200]!),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red[700]),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Methods
  void _showPersonalInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal Information'),
        content: const Text(
          'Personal information management will be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddressesDialog() {
    // This dialog is used to add a new address.
    // Saved addresses are displayed on the main profile screen via
    // `_buildSavedAddressesPanel()` so users can select them quickly.

    // Initialize form controllers with location data (new address entry)
    final nameCtrl = TextEditingController(text: nameController.text);
    final emailCtrl = TextEditingController(text: emailController.text);
    final phoneCtrl = TextEditingController(text: PhoneController.text);
    final streetCtrl = TextEditingController(text: 
   // locationData['street'] ??
     '');
    final apartmentCtrl = TextEditingController(text: '');
    final cityCtrl = TextEditingController(text: 
   // locationData['city'] ??
     '');
    final stateCtrl = TextEditingController(text: 
    //locationData['state'] ?? 
    '');
    final zipCtrl = TextEditingController(text: 
   // locationData['zip'] ?? 
    '');
    final countryCtrl = TextEditingController(text: 
   // locationData['country'] ?? 
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
                              key: _formkey,
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
                              if (_formkey.currentState!.validate()) {
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

                                // Update the class-level controllers for consistency
                                setState(() {
                                  nameController.text = nameCtrl.text.trim();
                                  emailController.text = emailCtrl.text.trim();
                                  PhoneController.text = phoneCtrl.text.trim();
                                  StreetController.text = streetCtrl.text.trim();
                                  ApartmentController.text = apartmentCtrl.text.trim();
                                  cityController.text = cityCtrl.text.trim();
                                  stateController.text = stateCtrl.text.trim();
                                  ZIPController.text = zipCtrl.text.trim();
                                  countryController.text = countryCtrl.text.trim();
                                  instructionsController.text = instructionsCtrl.text.trim();
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
    nameController.dispose();
    emailController.dispose();
    PhoneController.dispose();
    StreetController.dispose();
    ApartmentController.dispose();
    cityController.dispose();
    stateController.dispose();
    ZIPController.dispose();
    countryController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  void _showPaymentMethodsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Methods'),
        content: const Text(
          'Payment method management will be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showOrderHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order History'),
        content: const Text('Order history will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Information:'),
            SizedBox(height: 8),
            Text('📧 Email: support@trueharvest.com'),
            Text('📞 Phone: +91 12345678910'),
            Text('🕒 Hours: 9 AM - 6 PM (Mon-Sat)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text(
          'Notification preferences will be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'At True Harvest, we are committed to protecting your privacy and ensuring the security of your personal information...\n\n'
            'This is a placeholder for the full privacy policy content.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About True Harvest'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('True Harvest - Fresh Organic Products'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('Build: 1'),
            SizedBox(height: 8),
            Text('Delivering fresh, organic products to your doorstep.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout? This will clear your saved addresses.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Clear addresses from SharedPreferences
            await ref.read(addressProvider).clearAll();
            Navigator.pop(context);
            // Navigate to login screen
            AppRoutes.navigateTo(context, '/login');
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}
  // void _showLogoutDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Logout'),
  //       content: const Text('Are you sure you want to logout?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // Navigate to login screen
  //             AppRoutes.navigateTo(context, '/login');
  //           },
  //           style: TextButton.styleFrom(foregroundColor: Colors.red),
  //           child: const Text('Logout'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => const VerificationDialog(),
    );
  }
}

