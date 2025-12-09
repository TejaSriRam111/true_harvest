// controllers/address_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_new/models/address_model.dart';

final addressProvider = ChangeNotifierProvider<AddressController>(
  (ref) => AddressController()..loadAddresses(),
);

class AddressController extends ChangeNotifier {
  // Keys for SharedPreferences
  static const String _addressesKey = 'saved_addresses';
  static const String _selectedAddressKey = 'selected_address_id';
  
  // Keep a primary address for backward compatibility
  AddressModel? _address;
  // Maintain a list of saved addresses
  final List<AddressModel> _addresses = [];

  AddressModel? get address => _address;
  List<AddressModel> get addresses => List.unmodifiable(_addresses);

  // Load addresses from SharedPreferences
  Future<void> loadAddresses() async {
    try {
      
      _addresses.clear();
      final prefs = await SharedPreferences.getInstance();
      
      // Load all addresses
      final addressesJson = prefs.getStringList(_addressesKey) ?? [];
      final loadedAddresses = addressesJson
          .map((json) => AddressModel.fromJson(json))
          .toList();
      
      _addresses.addAll(loadedAddresses);
      
      // Load selected address
      final selectedId = prefs.getString(_selectedAddressKey);
      if (selectedId != null) {
        _address = _addresses.firstWhere(
          (addr) => addr.id == selectedId,
          orElse: () {
            // If no address found with that ID, use default or first one
            if (_addresses.isNotEmpty) {
              return _addresses.firstWhere(
                (addr) => addr.isDefault,
                orElse: () => _addresses.first,
              );
            }
            return AddressModel(
              name: '',
              email: '',
              phone: '',
              street: '',
              apartment: '',
              city: '',
              state: '',
              zip: '',
              country: '',
            );
          },
        );
      } else if (_addresses.isNotEmpty) {
        // Try to find default address or use first one
        _address = _addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => _addresses.first,
        );
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading addresses: $e');
      }
    }
  }

  // Save addresses to SharedPreferences
  Future<void> _saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = _addresses.map((addr) => addr.toJson()).toList();
      await prefs.setStringList(_addressesKey, addressesJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving addresses: $e');
      }
    }
  }

  // Save selected address ID
  Future<void> _saveSelectedAddressId(String? id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (id != null) {
        await prefs.setString(_selectedAddressKey, id);
      } else {
        await prefs.remove(_selectedAddressKey);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving selected address: $e');
      }
    }
  }

  // Check if address already exists (by content, not just ID)
  bool _addressExists(AddressModel address) {
    return _addresses.any((existing) => 
      existing.name == address.name &&
      existing.street == address.street &&
      existing.city == address.city &&
      existing.state == address.state &&
      existing.zip == address.zip &&
      existing.country == address.country
    );
  }

  // Find existing address by content
  AddressModel? _findExistingAddress(AddressModel address) {
    try {
      return _addresses.firstWhere((existing) => 
        existing.name == address.name &&
        existing.street == address.street &&
        existing.city == address.city &&
        existing.state == address.state &&
        existing.zip == address.zip &&
        existing.country == address.country
      );
    } catch (e) {
      return null;
    }
  }

  void updateAddress(AddressModel newAddress) {
    // Check if address already exists by content
    final existingAddress = _findExistingAddress(newAddress);
    
    if (existingAddress != null) {
      // Update existing address with new data (preserve the original ID)
      final updatedAddress = existingAddress.copyWith(
        name: newAddress.name,
        email: newAddress.email,
        phone: newAddress.phone,
        street: newAddress.street,
        apartment: newAddress.apartment,
        city: newAddress.city,
        state: newAddress.state,
        zip: newAddress.zip,
        country: newAddress.country,
        deliveryInstructions: newAddress.deliveryInstructions,
      );
      
      final index = _addresses.indexWhere((a) => a.id == existingAddress.id);
      if (index >= 0) {
        _addresses[index] = updatedAddress;
      }
      
      _address = updatedAddress;
    } else {
      // Add as new address
      _addresses.insert(0, newAddress);
      _address = newAddress;
    }
    
    _saveSelectedAddressId(_address!.id);
    _saveAddresses();
    notifyListeners();
  }

  void addAddress(AddressModel addr) {
    // Check if address already exists by content
    if (!_addressExists(addr)) {
      _addresses.insert(0, addr);
      _saveAddresses();
      notifyListeners();
    } else {
      // If it exists, just select it
      final existing = _findExistingAddress(addr);
      if (existing != null) {
        _address = existing;
        _saveSelectedAddressId(existing.id);
        notifyListeners();
      }
    }
  }

  void selectAddress(int index) {
    if (index >= 0 && index < _addresses.length) {
      _address = _addresses[index];
      _saveSelectedAddressId(_address!.id);
      notifyListeners();
    }
  }

  void selectAddressById(String id) {
    try {
      final address = _addresses.firstWhere((addr) => addr.id == id);
      _address = address;
      _saveSelectedAddressId(address.id);
      notifyListeners();
    } catch (e) {
      if (_addresses.isNotEmpty) {
        _address = _addresses.first;
        _saveSelectedAddressId(_address!.id);
        notifyListeners();
      }
    }
  }

  void setAsDefault(String id) {
    // Remove default from all addresses
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].id == id) {
        _addresses[i] = _addresses[i].copyWith(isDefault: true);
      } else if (_addresses[i].isDefault) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    
    if (_address?.id == id) {
      _address = _address!.copyWith(isDefault: true);
    }
    
    _saveAddresses();
    notifyListeners();
  }

  void clearAddress() {
    _address = null;
    _saveSelectedAddressId(null);
    notifyListeners();
  }

  void removeAddressAt(int index) {
    if (index >= 0 && index < _addresses.length) {
      final addressToRemove = _addresses[index];
      final wasSelected = _address?.id == addressToRemove.id;
      
      _addresses.removeAt(index);
      
      if (wasSelected) {
        if (_addresses.isNotEmpty) {
          // Find next default address or first one
          _address = _addresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => _addresses.first,
          );
          _saveSelectedAddressId(_address!.id);
        } else {
          _address = null;
          _saveSelectedAddressId(null);
        }
      }
      
      _saveAddresses();
      notifyListeners();
    }
  }

  void removeAddressById(String id) {
    final index = _addresses.indexWhere((addr) => addr.id == id);
    if (index >= 0) {
      removeAddressAt(index);
    }
  }

  bool get hasAddress => _address != null;

  String get addressSummary {
    if (_address == null) return 'No address saved';
    return _address!.shortAddress;
  }

  // Clear all addresses (for logout)
  Future<void> clearAll() async {
    _addresses.clear();
    _address = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_addressesKey);
    await prefs.remove(_selectedAddressKey);
    
    notifyListeners();
  }
}