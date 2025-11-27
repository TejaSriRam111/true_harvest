import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/subscription_controller.dart';
import 'package:task_new/models/product_model.dart';
import 'package:task_new/models/subscription_model.dart';
import 'package:task_new/routes/app_routes.dart';
import 'package:task_new/utils/app_colors.dart';

class CustomSubscriptionScreen extends ConsumerStatefulWidget {
  const CustomSubscriptionScreen({super.key});

  @override
  ConsumerState<CustomSubscriptionScreen> createState() => _CustomSubscriptionScreenState();
}

class _CustomSubscriptionScreenState extends ConsumerState<CustomSubscriptionScreen> {
  final List<SubscriptionItem> _selectedItems = [];
  SubscriptionType _selectedDuration = SubscriptionType.monthly;
  
  final List<Product> _availableProducts = [
    Product(
      id: 'milk_fresh',
      name: 'Fresh Milk',
      description: 'Pure organic milk',
      imageUrl: 'assets/images/milk.png',
      category: 'Milk',
      isFavorite: false,
      features: [],
      units: [
        ProductUnit(unitName: '500ml', price: 30.0),
        ProductUnit(unitName: '1L', price: 55.0),
      ],
    ),
    Product(
      id: 'curd_fresh',
      name: 'Fresh Curd',
      description: 'Homemade style curd',
      imageUrl: 'assets/images/curd.png',
      category: 'Curd',
      isFavorite: false,
      features: [],
      units: [
        ProductUnit(unitName: '200g', price: 25.0),
        ProductUnit(unitName: '500g', price: 60.0),
      ],
    ),
    Product(
      id: 'fruit_bowl',
      name: 'Fruit Bowl',
      description: 'Seasonal fresh fruits',
      imageUrl: 'assets/images/fruits.png',
      category: 'Fruits',
      isFavorite: false,
      features: [],
      units: [
        ProductUnit(unitName: 'Small', price: 80.0),
        ProductUnit(unitName: 'Large', price: 150.0),
      ],
    ),
    Product(
      id: 'dry_fruits',
      name: 'Dry Fruits Mix',
      description: 'Premium dry fruits',
      imageUrl: 'assets/images/dry_fruits.png',
      category: 'Dry Fruits',
      isFavorite: false,
      features: [],
      units: [
        ProductUnit(unitName: '250g', price: 200.0),
        ProductUnit(unitName: '500g', price: 380.0),
      ],
    ),
    Product(
      id: 'sprouts',
      name: 'Fresh Sprouts',
      description: 'Healthy mixed sprouts',
      imageUrl: 'assets/images/sprouts.png',
      category: 'Sprouts',
      isFavorite: false,
      features: [],
      units: [
        ProductUnit(unitName: '200g', price: 40.0),
        ProductUnit(unitName: '500g', price: 95.0),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: const Text(
          'Create Custom Plan',
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
          // Duration Selection
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Duration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: SubscriptionType.values.map((type) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_getDurationText(type)),
                          selected: _selectedDuration == type,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedDuration = type;
                              });
                            }
                          },
                          selectedColor: AppColors.darkGreen,
                          labelStyle: TextStyle(
                            color: _selectedDuration == type ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availableProducts.length,
              itemBuilder: (context, index) {
                final product = _availableProducts[index];
                return _buildProductCard(product);
              },
            ),
          ),

          // Bottom Summary
          if (_selectedItems.isNotEmpty) _buildBottomSummary(),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final existingItem = _selectedItems.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => SubscriptionItem(
        id: '',
        product: product,
        unit: product.units.first.unitName,
        quantity: 0,
        frequency: DeliveryFrequency.daily,
        pricePerDelivery: 0,
      ),
    );

    final isSelected = existingItem.quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.darkGreen, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₹${product.units.first.price}/unit',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isSelected,
                  onChanged: (value) {
                    if (value) {
                      _addProduct(product);
                    } else {
                      _removeProduct(product.id);
                    }
                  },
                  activeColor: AppColors.darkGreen,
                ),
              ],
            ),
            
            if (isSelected) ...[
              const SizedBox(height: 16),
              _buildProductOptions(product, existingItem),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductOptions(Product product, SubscriptionItem item) {
    return Column(
      children: [
        // Unit Selection
        Row(
          children: [
            const Text('Unit: ', style: TextStyle(fontWeight: FontWeight.w500)),
            Expanded(
              child: DropdownButton<String>(
                value: item.unit,
                isExpanded: true,
                items: product.units.map((unit) {
                  return DropdownMenuItem(
                    value: unit.unitName,
                    child: Text('${unit.unitName} - ₹${unit.price}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateItemUnit(product.id, value);
                  }
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Quantity Selection
        Row(
          children: [
            const Text('Quantity: ', style: TextStyle(fontWeight: FontWeight.w500)),
            IconButton(
              onPressed: item.quantity > 1 ? () => _updateQuantity(product.id, item.quantity - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: () => _updateQuantity(product.id, item.quantity + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Frequency Selection
        Row(
          children: [
            const Text('Delivery: ', style: TextStyle(fontWeight: FontWeight.w500)),
            Expanded(
              child: DropdownButton<DeliveryFrequency>(
                value: item.frequency,
                isExpanded: true,
                items: DeliveryFrequency.values.map((freq) {
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(_getFrequencyText(freq)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateFrequency(product.id, value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomSummary() {
    final totalPrice = _selectedItems.fold<double>(
      0,
      (sum, item) => sum + item.pricePerDelivery,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
              Text(
                '${_selectedItems.length} items selected',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                '₹${totalPrice.toStringAsFixed(2)}/${_getDurationText(_selectedDuration)}',
                style: const TextStyle(
                  fontSize: 18,
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
              onPressed: _createCustomSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create Subscription',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addProduct(Product product) {
    final item = SubscriptionItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      product: product,
      unit: product.units.first.unitName,
      quantity: 1,
      frequency: DeliveryFrequency.daily,
      pricePerDelivery: product.units.first.price,
    );
    
    setState(() {
      _selectedItems.add(item);
    });
  }

  void _removeProduct(String productId) {
    setState(() {
      _selectedItems.removeWhere((item) => item.product.id == productId);
    });
  }

  void _updateQuantity(String productId, int newQuantity) {
    setState(() {
      final index = _selectedItems.indexWhere((item) => item.product.id == productId);
      if (index != -1) {
        final item = _selectedItems[index];
        final unitPrice = item.product.units
            .firstWhere((unit) => unit.unitName == item.unit)
            .price;
        
        _selectedItems[index] = item.copyWith(
          quantity: newQuantity,
          pricePerDelivery: unitPrice * newQuantity,
        );
      }
    });
  }

  void _updateItemUnit(String productId, String newUnit) {
    setState(() {
      final index = _selectedItems.indexWhere((item) => item.product.id == productId);
      if (index != -1) {
        final item = _selectedItems[index];
        final unitPrice = item.product.units
            .firstWhere((unit) => unit.unitName == newUnit)
            .price;
        
        _selectedItems[index] = item.copyWith(
          unit: newUnit,
          pricePerDelivery: unitPrice * item.quantity,
        );
      }
    });
  }

  void _updateFrequency(String productId, DeliveryFrequency frequency) {
    setState(() {
      final index = _selectedItems.indexWhere((item) => item.product.id == productId);
      if (index != -1) {
        _selectedItems[index] = _selectedItems[index].copyWith(frequency: frequency);
      }
    });
  }

  String _getDurationText(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.daily: return 'Daily';
      case SubscriptionType.weekly: return 'Weekly';
      case SubscriptionType.monthly: return 'Monthly';
      case SubscriptionType.quarterly: return 'Quarterly';
      case SubscriptionType.yearly: return 'Yearly';
    }
  }

  String _getFrequencyText(DeliveryFrequency frequency) {
    switch (frequency) {
      case DeliveryFrequency.daily: return 'Daily';
      case DeliveryFrequency.everyOtherDay: return 'Every Other Day';
      case DeliveryFrequency.weekly: return 'Weekly';
      case DeliveryFrequency.biWeekly: return 'Bi-Weekly';
      case DeliveryFrequency.monthly: return 'Monthly';
    }
  }

  void _createCustomSubscription() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to address input screen or show bottom sheet
    _showAddressInput();
  }

  void _showAddressInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressInputSheet(
        selectedItems: _selectedItems,
        duration: _selectedDuration,
      ),
    );
  }
}

class _AddressInputSheet extends ConsumerStatefulWidget {
  final List<SubscriptionItem> selectedItems;
  final SubscriptionType duration;

  const _AddressInputSheet({
    required this.selectedItems,
    required this.duration,
  });

  @override
  ConsumerState<_AddressInputSheet> createState() => _AddressInputSheetState();
}

class _AddressInputSheetState extends ConsumerState<_AddressInputSheet> {
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your complete delivery address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.darkGreen),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Delivery Instructions (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _instructionsController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Any specific delivery instructions',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.darkGreen),
                ),
              ),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Create Subscription',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSubscription() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create custom plan
    final customPlan = SubscriptionPlan(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Custom Plan',
      description: 'Your personalized subscription',
      type: widget.duration,
      price: widget.selectedItems.fold(0.0, (sum, item) => sum + item.pricePerDelivery),
      originalPrice: widget.selectedItems.fold(0.0, (sum, item) => sum + item.pricePerDelivery),
      durationInDays: _getDurationDays(widget.duration),
      features: widget.selectedItems.map((item) => '${item.product.name} (${item.quantity}x ${item.unit})').toList(),
      imageUrl: '',
      discount: 0,
    );

    final subscriptionController = ref.read(subscriptionProvider);
    final success = await subscriptionController.createSubscription(
      plan: customPlan,
      items: widget.selectedItems,
      deliveryAddress: _addressController.text.trim(),
      deliveryInstructions: _instructionsController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom subscription created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      AppRoutes.navigateTo(context, '/subscription');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create subscription. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getDurationDays(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.daily: return 30;
      case SubscriptionType.weekly: return 30;
      case SubscriptionType.monthly: return 30;
      case SubscriptionType.quarterly: return 90;
      case SubscriptionType.yearly: return 365;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}
