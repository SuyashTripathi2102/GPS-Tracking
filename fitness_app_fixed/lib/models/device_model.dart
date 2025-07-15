class DeviceModel {
  final int? id;
  final String name;
  final String deviceId;
  final int batteryLevel;
  final String lastSyncTime;
  final bool isOnline;

  DeviceModel({
    this.id,
    required this.name,
    required this.deviceId,
    required this.batteryLevel,
    required this.lastSyncTime,
    required this.isOnline,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'deviceId': deviceId,
    'batteryLevel': batteryLevel,
    'lastSyncTime': lastSyncTime,
    'isOnline': isOnline ? 1 : 0,
  };

  factory DeviceModel.fromMap(Map<String, dynamic> map) => DeviceModel(
    id: map['id'],
    name: map['name'],
    deviceId: map['deviceId'],
    batteryLevel: map['batteryLevel'],
    lastSyncTime: map['lastSyncTime'],
    isOnline: map['isOnline'] == 1,
  );
}
