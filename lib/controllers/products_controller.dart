import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_new/utils/app_constants.dart';

import '../models/product_model.dart';

final groceryHomeControllerProvider =
    ChangeNotifierProvider<GroceryHomeController>(
      (ref) => GroceryHomeController(),
    );

class GroceryHomeController extends ChangeNotifier {
  String _selectedCategory;
  final List<ProductCategory> _categories;
  final List<Product> _products;
  String _searchValue = "";

  String get searchValue => _searchValue;

  GroceryHomeController()
    : _selectedCategory = 'All',
      _categories = _initialCategories(),
      _products = _initialProducts();

  String get selectedCategory => _selectedCategory;
  List<ProductCategory> get categories =>
      List<ProductCategory>.unmodifiable(_categories);
  List<Product> get products => List<Product>.unmodifiable(_products);

  void clearSearch() {
    _searchValue = '';
    notifyListeners();
  }

  List<Product> get filteredProducts {
    List<Product> filtered = _products;

    // Apply category filter
    if (_selectedCategory != 'All') {
      final categoryType = categoryMap[_selectedCategory];
      if (categoryType != null) {
        filtered = filtered.where((p) => p.category == categoryType).toList();
      }
    }

    // Apply search filter
    // Apply search filter
    if (_searchValue.trim().isNotEmpty) {
      final query = _searchValue.toLowerCase().replaceAll(" ", "");

      filtered = filtered.where((p) {
        final name = p.name.toLowerCase().replaceAll(" ", "");
        final desc = p.description.toLowerCase().replaceAll(" ", "");

        return name.contains(query) || desc.contains(query);
      }).toList();
    }

    return filtered;
  }

  List<Product> getListData(String searchValue, List<Product> data) {
    if (searchValue.trim().isNotEmpty) {
      return data
          .where(
            (e) => e.name
                .replaceAll(" ", "")
                .contains(searchValue.replaceAll(" ", "")),
          )
          .toList();
    } else {
      return data;
    }
  }

  void updateSearch(String val) {
    _searchValue = val;
    notifyListeners();
  }

  // Map UI category names to CategoryType values
  static Map<String, CategoryType> categoryMap = {
    'Milk': CategoryType.milk,
    'Curd': CategoryType.curd,
    'Honey': CategoryType.honey,
    'Paneer': CategoryType.paneer,
    'Sprouts': CategoryType.sprouts,
    'Dry Fruits': CategoryType.dryFruits,
    'Fruits': CategoryType.fruit,
  };

  void selectCategory(String categoryName) {
    if (_selectedCategory != categoryName) {
      _selectedCategory = categoryName;
      notifyListeners();
    }
  }

  void toggleFavorite(String productId) {
    final int index = _products.indexWhere(
      (Product product) => product.id == productId,
    );
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        isFavorite: !_products[index].isFavorite,
      );
      notifyListeners();
    }
  }

  static List<ProductCategory> _initialCategories() {
    return <ProductCategory>[
      ProductCategory(name: 'All'),
      ProductCategory(name: 'Milk'),
      ProductCategory(name: 'Curd'),
      ProductCategory(name: 'Honey'),
      ProductCategory(name: 'Paneer'),
      ProductCategory(name: 'Sprouts'),
      ProductCategory(name: 'Dry Fruits'),
      ProductCategory(name: 'Fruits'),
    ];
  }

  static List<Product> _initialProducts() {
    return <Product>[
      // MILK
      Product(
        id: 'p1',
        category: CategoryType.milk,
        name: 'Organic Milk',
        imageUrl: 'assets/products/milk.jpeg',
        isFavorite: false,
        description:
            "Fresh, creamy organic whole milk sourced from pasture-raised cows. Perfect for daily nutrition.",
        features: [
          "100% organic",
          "Rich in calcium",
          "Creamy texture",
          "Ideal for kids and adults",
        ],
        units: [
          ProductUnit(unitName: "500 ml", price: 35), // ₹35
          ProductUnit(unitName: "1 L", price: 65), // ₹65
        ],
      ),

      // CURD
      Product(
        id: 'p2',
        category: CategoryType.curd,
        name: 'Homemade Fresh Curd',
        imageUrl: 'assets/products/curdPot.jpeg',
        isFavorite: false,
        description:
            "Thick, creamy homemade curd made from fresh milk. Perfect for digestion and meals.",
        features: [
          "Probiotic-rich",
          "No preservatives",
          "Smooth texture",
          "Ideal for daily meals",
        ],
        units: [
          ProductUnit(unitName: "500 ml", price: 70), // ₹15
          ProductUnit(unitName: "1 L", price: 150), // ₹55
        ],
      ),

      // HONEY
      Product(
        id: 'p3',
        category: CategoryType.honey,
        name: 'Organic Raw Honey',
        units: [
          ProductUnit(unitName: "500 ml", price: 225), // ₹225
          ProductUnit(unitName: "1 L", price: 420), // ₹420
        ],
        description:
            "Pure, unprocessed raw honey collected from natural bee farms. Rich in antioxidants and natural sweetness.",
        features: [
          "100% pure raw honey",
          "No added sugar or preservatives",
          "Rich in antioxidants",
          "Boosts immunity & energy",
        ],
        imageUrl: 'assets/products/honey.jpeg',
        isFavorite: false,
      ),

      // PANEER
      Product(
        id: 'p4',
        category: CategoryType.paneer,
        name: 'Fresh Malai Paneer',
        units: [
          ProductUnit(unitName: "200 g", price: 85), // ₹85
          ProductUnit(unitName: "500 g", price: 210), // ₹210
        ],
        description:
            "Soft and creamy malai paneer made from fresh farm milk. Perfect for curries, snacks, and grilling.",
        features: [
          "Rich creamy texture",
          "High protein content",
          "Freshly made daily",
          "Ideal for Indian dishes",
        ],
        imageUrl: 'assets/products/panner.jpeg',
        isFavorite: false,
      ),

      // SPROUTS
      Product(
        id: 'p5',
        category: CategoryType.sprouts,
        name: 'Fresh Mixed Sprouts',
        units: [
          ProductUnit(unitName: "1 box (250 g)", price: 45), // ₹45
        ],
        description:
            "A healthy mix of green gram, chickpea, and lentil sprouts. Ready-to-eat, high in protein and fiber.",
        features: [
          "Rich in plant protein",
          "Improves digestion",
          "Ready to eat",
          "Perfect for salads & snacks",
        ],
        imageUrl: 'assets/products/sprutos.jpeg',
        isFavorite: false,
      ),

      // FRUIT BOWL
      Product(
        id: 'p6',
        category: CategoryType.fruit,
        name: 'Fresh Fruit Bowl',
        units: [
          ProductUnit(unitName: "1 Box (300 g)", price: 80), // ₹80
        ],
        description:
            "A refreshing bowl of seasonal fresh fruits, cut and packed hygienically. Great for a light and healthy snack.",
        features: [
          "Contains seasonal assorted fruits",
          "Ready to eat",
          "Hygienically packed",
          "Perfect for breakfast & snacks",
        ],
        imageUrl: 'assets/products/fruitBowl.jpeg',
        isFavorite: false,
      ),

      // DRY FRUITS
      Product(
        id: 'p7',
        category: CategoryType.dryFruits,
        name: 'Premium Dry Fruits Mix',
        units: [
          ProductUnit(unitName: "250 g", price: 299), // ₹299
        ],
        description:
            "A premium mix of almonds, cashews, raisins, pistachios, and walnuts. Perfect for daily nutrition.",
        features: [
          "Rich in healthy fats",
          "Great for snacking",
          "Boosts energy & immunity",
          "Premium quality nuts",
        ],
        imageUrl: 'assets/products/dryfruits.jpeg',
        isFavorite: false,
      ),
    ];
  }
}
