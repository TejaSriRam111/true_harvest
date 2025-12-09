// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  // Get detailed address components from coordinates
  static Future<Map<String, String>> getDetailedAddressFromLatLng(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return {
          'street': place.street ?? '',
          'city': place.locality ?? '',
          'state': place.administrativeArea ?? '',
          'country': place.country ?? 'India',
          'zip': place.postalCode ?? '',
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
        };
      }
      return {
        'street': '',
        'city': 'Unknown',
        'state': 'Unknown',
        'country': 'India',
        'zip': '',
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };
    } catch (e) {
      return {
        'street': '',
        'city': 'Unknown',
        'state': 'Unknown',
        'country': 'India',
        'zip': '',
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };
    }
  }
}
