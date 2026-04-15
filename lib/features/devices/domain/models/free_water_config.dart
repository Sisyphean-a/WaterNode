class FreeWaterConfig {
  const FreeWaterConfig({
    required this.id,
    required this.beanValue,
    required this.waterVolume,
    required this.dayLimit,
    required this.isOn,
    this.description,
  });

  final String id;
  final int beanValue;
  final double waterVolume;
  final int dayLimit;
  final bool isOn;
  final String? description;
}
