// controllers/address_controller.dart
import 'package:flutter/foundation.dart';
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
  // Track selected address
  AddressModel? _selectedAddress;

  AddressModel? get address => _selectedAddress ?? _address;
  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  AddressModel? get selectedAddress => _selectedAddress;

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
        _selectedAddress = _addresses.firstWhere(
          (addr) => addr.id == selectedId,
          orElse: () => _addresses.isNotEmpty ? _addresses.first : AddressModel.empty(),
        );
      } else if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses.first;
      }
      
      // For backward compatibility
      _address = _selectedAddress;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }
  }

  // Save addresses to SharedPreferences
  Future<void> _saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = _addresses.map((addr) => addr.toJson()).toList();
      await prefs.setStringList(_addressesKey, addressesJson);
      
      if (_selectedAddress != null) {
        await prefs.setString(_selectedAddressKey, _selectedAddress!.id);
      }
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }

  // Add a new address
  Future<void> addAddress(AddressModel newAddress) async {
    try {
      // If address with same ID exists, update it
      final existingIndex = _addresses.indexWhere((a) => a.id == newAddress.id);
      if (existingIndex >= 0) {
        _addresses[existingIndex] = newAddress;
      } else {
        _addresses.add(newAddress);
      }
      
      // If this is the first address, select it
      if (_addresses.length == 1) {
        _selectedAddress = newAddress;
      }
      
      await _saveAddresses();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    }
  }

  // Update an existing address
  Future<void> updateAddress(AddressModel updatedAddress) async {
    try {
      final index = _addresses.indexWhere((a) => a.id == updatedAddress.id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        if (_selectedAddress?.id == updatedAddress.id) {
          _selectedAddress = updatedAddress;
        }
        await _saveAddresses();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  // Remove an address
  Future<void> removeAddress(String addressId) async {
    try {
      _addresses.removeWhere((addr) => addr.id == addressId);
      
      // If the removed address was selected, select another one
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }
      
      await _saveAddresses();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing address: $e');
      rethrow;
    }
  }

  // Select an address by ID
  Future<void> selectAddressById(String id) async {
    try {
      final address = _addresses.firstWhere(
        (addr) => addr.id == id,
        orElse: () => throw Exception('Address not found'),
      );
      _selectedAddress = address;
      _address = address; // For backward compatibility
      await _saveAddresses();
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting address: $e');
      rethrow;
    }
  }

  // Select an address
  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    _address = address; // For backward compatibility
    _saveSelectedAddressId(address.id);
    notifyListeners();
  }

  // Clear all addresses
  Future<void> clearAddresses() async {
    _addresses.clear();
    _selectedAddress = null;
    _address = null;
    await _saveAddresses();
    notifyListeners();
  }

  // Clear only the form fields
  void clearAddressFields() {
    _address = AddressModel.empty();
    notifyListeners();
  }

  // Helper method to save selected address ID
  Future<void> _saveSelectedAddressId(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedAddressKey, id);
    } catch (e) {
      debugPrint('Error saving selected address ID: $e');
    }
  }

  // Find existing address by content
  AddressModel? _findExistingAddress(AddressModel address) {
    try {
      if (addresses.isNotEmpty) {
        return _addresses.firstWhere(
          (existing) => 
            existing.name == address.name &&
            existing.street == address.street &&
            existing.city == address.city &&
            existing.state == address.state &&
            existing.zip == address.zip &&
            existing.country == address.country
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}