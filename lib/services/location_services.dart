// lib/services/location_service.dart
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:task_new/models/address_model.dart';

class LocationService {
  // Get current location
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      
      await Geolocator.openAppSettings();
      return null;
    }

    // Get current position
    return await Geolocator.getCurrentPosition();
  }

  // Get address from coordinates
  static Future<String> getAddressFromLatLng(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.locality ?? ''}, ${place.administrativeArea ?? ''}'
            .trim();
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  // Get detailed address components from coordinates as AddressFormState
  static Future<AddressModel> getDetailedAddressFromLatLng(Position position) async {
  try {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '', // Will be filled by user
      
        street: place.street ?? '',
        city: place.locality ?? place.subAdministrativeArea ?? '',
        state: place.administrativeArea ?? '',
        country: place.country ?? 'India',
        zip: place.postalCode ?? '',
        isDefault: false, // Let the address controller handle default status
        deliveryInstructions: null, // Will be filled by user if needed
      );
    }
    
    // Return a default address model if no placemarks found
    return AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
    
      street: '',
      city: 'Unknown',
      state: 'Unknown',
      country: 'India',
      zip: '',
      isDefault: false,
      deliveryInstructions: null,

    );
  } catch (e) {
    // Return a default address model in case of any error
    return AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
     
      street: '',
    
      city: 'Unknown',
      state: 'Unknown',
      country: 'India',
      zip: '',
      isDefault: false,
      deliveryInstructions: null,
    );
  }
}
}


