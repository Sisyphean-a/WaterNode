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

  factory DeviceStation.fromMap(Map<dynamic, dynamic> data) {
    return DeviceStation(
      id: data['id'] as String,
      name: data['name'] as String,
      status: data['status'] as String,
      regionCode: data['regionCode'] as String,
      deviceNum: data['deviceNum'] as String,
      address: data['address'] as String?,
      isOnline: data['isOnline'] as bool? ?? false,
      dispenserType: data['dispenserType'] as String?,
      dispenserTypeDesc: data['dispenserTypeDesc'] as String?,
      statusDescription: data['statusDescription'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'status': status,
      'regionCode': regionCode,
      'deviceNum': deviceNum,
      'address': address,
      'isOnline': isOnline,
      'dispenserType': dispenserType,
      'dispenserTypeDesc': dispenserTypeDesc,
      'statusDescription': statusDescription,
      'latitude': latitude,
      'longitude': longitude,
      'distanceKm': distanceKm,
    };
  }
}
