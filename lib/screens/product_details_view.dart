// lib/screens/each_item_view.dart
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/cart_controller.dart';
import 'package:task_new/controllers/whishlist_provider.dart';
import 'package:task_new/models/cart_item.dart';
import 'package:task_new/models/product_model.dart';
import 'package:task_new/screens/cart_screen.dart';
import 'package:task_new/screens/subscription_plan_screen.dart';
import 'package:task_new/utils/app_colors.dart';
import 'package:task_new/utils/app_constants.dart';
import 'package:task_new/widgets/quantity_handler.dart';

class ProductDetailsView extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailsView({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsView> createState() => _EachItemViewState();
}

class _EachItemViewState extends ConsumerState<ProductDetailsView> {
  int quantity = 1;
  final ScrollController _scrollController = ScrollController();
  // bool _showTitle = false;
  int selectedUnitIndex = 0;
  late final wishlistProviderController = ref.read(wishlistProvider);
  late final cartProviderController = ref.read(cartProvider);
  bool _showGoToCart = false;
  bool _isBuyingNow = false;
  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll);
    final isItemsInCart = ref.read(cartProvider).items.isNotEmpty;
    if (isItemsInCart) {
      setState(() {
        _showGoToCart = true;
      });
    }
  }

  // void _onScroll() {
  //   if (_scrollController.offset > 100 && !_showTitle) {
  //     setState(() => _showTitle = true);
  //   } else if (_scrollController.offset <= 100 && _showTitle) {
  //     setState(() => _showTitle = false);
  //   }
  // }

  @override
  void dispose() {
    // _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider).items;

    // Check if current product is in cart
    final isItemInCart = cartItems.any(
      (item) =>
          item.product.id == widget.product.id &&
          item.selectedUnit == widget.product.units[selectedUnitIndex].unitName,
    );

    // Update local state if needed
    if (_showGoToCart != isItemInCart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showGoToCart = isItemInCart;
          });
        }
      });
    }

    // Get the cart item if it exists
    final cartItem = cartItems.firstWhere(
      (item) =>
          item.product.id == widget.product.id &&
          item.selectedUnit == widget.product.units[selectedUnitIndex].unitName,
      orElse: () => CartItem(
        product: widget.product,
        selectedUnit: widget.product.units[selectedUnitIndex].unitName,
        quantity: 0,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  final wishlistViewController = ref.watch(wishlistProvider);
                  return IconButton(
                    icon: Icon(
                      wishlistViewController.isInWishlist(widget.product)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: wishlistViewController.isInWishlist(widget.product)
                          ? Colors.red
                          : AppColors.black,
                    ),
                    onPressed: () {
                      wishlistProviderController.toggleWishlist(widget.product);
                    },
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Hero(
                tag: 'product-${widget.product.id}',
                child: Image.asset(widget.product.imageUrl, fit: BoxFit.cover),
              ),
              title: Text(''),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product.category.name,
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        '₹${widget.product.units[selectedUnitIndex].price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Available Units",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 10,
                        children: List.generate(widget.product.units.length, (
                          index,
                        ) {
                          final unit = widget.product.units[index];

                          final isSelected = selectedUnitIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedUnitIndex = index;
                              });
                            },
                            child: DottedBorder(
                              color: isSelected
                                  ? AppColors.darkGreen
                                  : AppColors.grey,
                              strokeWidth: 1.2,
                              dashPattern: [5, 4],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(16),

                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.darkGreen.withOpacity(0.08)
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  unit.unitName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.darkGreen
                                        : AppColors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );

                          //                           DottedBorder(
                          //   color: isSelected ? AppColors.darkGreen : Colors.grey,
                          //   strokeWidth: 1.2,
                          //   dashPattern: [5, 4],
                          //   borderType: BorderType.RRect,
                          //   radius: const Radius.circular(18),

                          //   // Add padding for clean spacing
                          //   child: Padding(
                          //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),

                          //     child: ChoiceChip(
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(16),
                          //       ),
                          //       labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),

                          //       label: Text(
                          //         unit.unitName,
                          //         style: TextStyle(
                          //           color: isSelected ? Colors.white : AppColors.darkGreen,
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),

                          //       selected: isSelected,
                          //       selectedColor: AppColors.darkGreen,
                          //       backgroundColor: Colors.transparent, // let dotted border show cleanly

                          //       onSelected: (_) {
                          //         setState(() {
                          //           selectedUnitIndex = index;
                          //         });
                          //       },
                          //     ),
                          //   ),
                          // );

                          // ChoiceChip(
                          //   label: Text(
                          //     unit.unitName,
                          //     style: TextStyle(
                          //       color: isSelected
                          //           ? Colors.white
                          //           : AppColors.darkGreen,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          //   selected: isSelected,
                          //   selectedColor: AppColors.darkGreen,
                          //   backgroundColor: Colors.grey.shade200,
                          //   onSelected: (_) {
                          //     setState(() {
                          //       selectedUnitIndex = index;
                          //     });
                          //   },
                          // );
                        }),
                      ),
                    ],
                  ),

                  // // Quantity Selector
                  // const Text(
                  //   'Quantity',
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 12),
                  // // Then in your widget tree:
                  // // In your ProductDetailsView build method
                  // // In your product_details_view.dart, update the QuantityHandler usage:
                  // QuantityHandler(
                  //   product: widget.product,
                  //   unit: widget.product.units[selectedUnitIndex].unitName,
                  //   initialQuantity: cartItem.quantity,
                  //   onQuantityChanged: (newQuantity) {
                  //     // final cartController = ref.read(cartProvider);
                  //     cartProviderController.updateQuantity(
                  //       widget.product,
                  //       widget.product.units[selectedUnitIndex].unitName,
                  //       newQuantity,
                  //     );
                  //     setState(() {
                  //       quantity = newQuantity;
                  //     });
                  //   },
                  // ),
                  const SizedBox(height: 25),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // FEATURES
                  const Text(
                    "Features",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ...widget.product.features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 10,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            f,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.darkGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.product.category.isMilk ||
                widget.product.category.isCurd ||
                widget.product.category.isButter ||
                widget.product.category.isdryFruits ||
                widget.product.category.issprouts ||
                widget.product.category.isfruit)
              // Subscription Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _goToSubscription,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkGreen,
                    side: BorderSide(color: AppColors.darkGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.subscriptions, size: 18),
                  label: const Text(
                    'Subscribe & Save',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            // Only show Add to Cart and Buy Now buttons if product is not Milk, Curd, or Butter
            if (!widget.product.category.isMilk &&
                !widget.product.category.isCurd &&
                !widget.product.category.isButter &&
                !widget.product.category.isdryFruits &&
                !widget.product.category.issprouts &&
                !widget.product.category.isfruit)
              Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                      child: _showGoToCart
                          ? ElevatedButton(
                              key: const ValueKey("goToCart"),
                              onPressed: _goToCart,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: AppColors.darkGreen,
                                minimumSize: const Size(
                                  double.infinity,
                                  54,
                                ), // Added height
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Go to Cart",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ElevatedButton.icon(
                              key: const ValueKey("addToCart"),
                              onPressed: _handleAddToCart,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(
                                  double.infinity,
                                  54,
                                ), // Added same height
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.shopping_cart_outlined),
                              label: const Text('Add to Cart'),
                            ),
                    ),
                  ),

                  // Expanded(
                  //   child: _showGoToCart
                  //       ? ElevatedButton(
                  //           key: const ValueKey("goToCart"),
                  //           onPressed: _goToCart,
                  //           style: ElevatedButton.styleFrom(
                  //             padding: const EdgeInsets.symmetric(vertical: 16),
                  //             backgroundColor: AppColors.darkGreen,
                  //             minimumSize: const Size(double.infinity, 42),
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //           ),
                  //           child: const Text(
                  //             "Go to Cart",
                  //             style: TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 14,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //         )
                  //       : ElevatedButton.icon(
                  //           onPressed: _handleAddToCart,
                  //           style: ElevatedButton.styleFrom(
                  //             padding: const EdgeInsets.symmetric(vertical: 16),
                  //             backgroundColor: AppColors.primary,
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(12),
                  //             ),
                  //           ),
                  //           icon: const Icon(Icons.shopping_cart_outlined),
                  //           label: const Text('Add to Cart'),
                  //         ),
                  // ),
                  const SizedBox(width: 16),

                  // Buy Now Button - Always visible
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isBuyingNow ? null : _handleBuyNow,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.darkGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isBuyingNow
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Buy Now',
                              style: TextStyle(color: AppColors.white),
                            ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _handleAddToCart() {
    final selectedUnit = widget.product.units[selectedUnitIndex];
    cartProviderController.addToCart(widget.product, selectedUnit.unitName);
    // State will be updated by the build method
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  void _goToSubscription() {
    final selectedUnit = widget.product.units[selectedUnitIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionPlanScreen(
          product: widget.product,
          selectedUnit: selectedUnit.unitName,
        ),
      ),
    );
  }

  void _handleBuyNow() async {
    if (_isBuyingNow) return;

    setState(() {
      _isBuyingNow = true;
    });

    try {
      // Get current cart items to find the quantity for this product
      final cartItems = ref.read(cartProvider).items;
      final selectedUnit = widget.product.units[selectedUnitIndex];

      // Find current quantity from cart or use 1 as default
      final existingItem = cartItems.firstWhere(
        (item) =>
            item.product.id == widget.product.id &&
            item.selectedUnit == selectedUnit.unitName,
        orElse: () => CartItem(
          product: widget.product,
          selectedUnit: selectedUnit.unitName,
          quantity: 1,
        ),
      );

      final currentQuantity = existingItem.quantity;

      // Use the new buyNow method for cleaner implementation
      await cartProviderController.buyNow(
        widget.product,
        selectedUnit.unitName,
        currentQuantity,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.product.name} added to cart for immediate purchase!',
            ),
            backgroundColor: AppColors.darkGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Navigate to cart screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add product to cart. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBuyingNow = false;
        });
      }
    }
  }
}
