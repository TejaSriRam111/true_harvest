// lib/providers/location_provider.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_new/models/location_state.dart';
import 'package:task_new/services/location_services.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier();
  },
);

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await Future.delayed(Duration(seconds: 1));
      final position = await LocationService.getCurrentLocation();

      if (position != null) {
        final address = await LocationService.getAddressFromLatLng(position);
        final detailedAddress = await LocationService.getDetailedAddressFromLatLng(position);
        state = state.copyWith(
          isLoading: false,
          location: address,
          detailedAddress: detailedAddress,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          location: 'Location not available',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error fetching location',
      );
    }
  }

  Future<void> updateLocation() async {
    await getCurrentLocation();
  }
}
