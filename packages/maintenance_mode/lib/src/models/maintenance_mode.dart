class MaintenanceMode {
  MaintenanceMode({
    required this.enabled,
    required this.maintenanceDescription,
  });

  bool enabled;
  String maintenanceDescription;

  factory MaintenanceMode.fromJson(Map<String, dynamic>? json) => MaintenanceMode(
    enabled: json?["enabled"],
    maintenanceDescription: json?["maintenanceDescription"],
  );

  Map<String, dynamic> toJson() => {
    "enabled": enabled,
    "maintenanceDescription": maintenanceDescription,
  };
}
