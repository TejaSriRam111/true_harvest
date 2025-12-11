import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/address_controller.dart';
import 'package:task_new/controllers/location_provider.dart';
import 'package:task_new/models/address_model.dart';
class AddressSelectionList extends ConsumerWidget {
  final VoidCallback? onAddressSelected;
  final VoidCallback? onLocationSelected;

  const AddressSelectionList({
    super.key,
    this.onAddressSelected,
    this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressCtrl = ref.watch(addressProvider);
    final locationState = ref.watch(locationProvider);
    final savedAddresses = addressCtrl.addresses;
    
    final hasLocation = locationState.detailedAddress != null &&
        (locationState.detailedAddress!.street.isNotEmpty || 
         locationState.detailedAddress!.fullAddress.isNotEmpty);

    if (savedAddresses.isEmpty && !hasLocation) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: const Text('No saved addresses. Please add an address.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Location Option
        if (hasLocation) ...[
          RadioListTile<AddressModel?>(
            value: locationState.detailedAddress,
            groupValue: addressCtrl.selectedAddress,
            title: const Text('Current Location'),
            subtitle: Text(
              locationState.detailedAddress?.fullAddress ?? 'Using current location',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onChanged: (address) {
              if (address != null) {
                addressCtrl.selectAddress(address);
                onLocationSelected?.call();
              }
            },
          ),
          if (savedAddresses.isNotEmpty) const Divider(),
        ],

        // Saved Addresses
        ...savedAddresses.map((address) {
          return Column(
            children: [
              RadioListTile<AddressModel>(
                value: address,
                groupValue: addressCtrl.selectedAddress,
                title: Text(address.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.fullAddress),
                    if (address.deliveryInstructions?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Instructions: ${address.deliveryInstructions}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
                onChanged: (selectedAddress) {
                  if (selectedAddress != null) {
                    addressCtrl.selectAddress(selectedAddress);
                    onAddressSelected?.call();
                  }
                },
              ),
              if (address != savedAddresses.last) const Divider(),
            ],
          );
        }).toList(),
      ],
    );
  }
}