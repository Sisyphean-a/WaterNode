class DeviceStation {
  const DeviceStation({
    required this.id,
    required this.name,
    required this.status,
    required this.regionCode,
    required this.deviceNum,
    this.address,
    this.isOnline = false,
    this.dispenserType,
    this.dispenserTypeDesc,
    this.statusDescription,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String status;
  final String regionCode;
  final String deviceNum;
  final String? address;
  final bool isOnline;
  final String? dispenserType;
  final String? dispenserTypeDesc;
  final String? statusDescription;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
}
