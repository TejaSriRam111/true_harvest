class LocationState {
  final bool isLoading;
  final String location;
  final String? error;
  final Map<String, String>? detailedAddress;

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
    Map<String, String>? detailedAddress,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      location: location ?? this.location,
      error: error,
      detailedAddress: detailedAddress ?? this.detailedAddress,
    );
  }
}
