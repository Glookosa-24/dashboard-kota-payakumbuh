class DistrictData {
  final String id;
  final String name;
  final String tag;
  final int population;
  final double xPercent;
  final double yPercent;
  final String colorHex;

  const DistrictData({
    required this.id,
    required this.name,
    required this.tag,
    required this.population,
    required this.xPercent,
    required this.yPercent,
    required this.colorHex,
  });
}

class RfidSensorNode {
  final String id;
  final String location;
  final String route;
  final int dailyTaps;
  final double uptime;
  final bool isOnline;

  const RfidSensorNode({
    required this.id,
    required this.location,
    required this.route,
    required this.dailyTaps,
    required this.uptime,
    required this.isOnline,
  });
}

class CyberSecurityState {
  final int blockedAnomalies;
  final bool encryptionActive;
  final double threatLevelPercent;
  final String threatStatus;

  const CyberSecurityState({
    required this.blockedAnomalies,
    required this.encryptionActive,
    required this.threatLevelPercent,
    required this.threatStatus,
  });
}
