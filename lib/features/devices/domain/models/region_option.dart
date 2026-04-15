class RegionOption {
  const RegionOption({
    required this.code,
    required this.name,
    this.children = const <RegionOption>[],
  });

  final String code;
  final String name;
  final List<RegionOption> children;
}
