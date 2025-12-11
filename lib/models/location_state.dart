import 'package:task_new/models/address_model.dart';

class LocationState {
  final bool isLoading;
  final String location;
  final String? error;
  final AddressModel? detailedAddress;

  LocationState({
    this.isLoading = false,
    this.location = '',
    this.error,
    this.detailedAddress,
  });

  LocationState copyWith({
    bool? isLoading,
    String? location,
    String? error,
    AddressModel? detailedAddress,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      location: location ?? this.location,
      error: error,
      detailedAddress: detailedAddress ?? this.detailedAddress,
    );
  }
}
