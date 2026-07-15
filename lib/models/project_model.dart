import 'package:shuttles_of_the_mill_row/enum/my_enums.dart';

class WeavingShuttleModel {
  String id;
  String shuttleRegistryMark;
  FiberType fiberType;
  LoomApplicationClass loomApplicationClass;
  String artisanHallmark;
  String internalBobbinCapacity;
  ThreadDeliveryEyelet threadDeliveryEyelet;
  TimberHardwood timberHardwood;
  TipMetallurgy tipMetallurgy;
  String physicalProportions;
  TrackFrictionWear trackFrictionWear;
  String weavingGroundZero;
  String temperatureRange;
  String era;
  String calibratedSite;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  WeavingShuttleModel({
    required this.id,
    required this.shuttleRegistryMark,
    required this.fiberType,
    required this.loomApplicationClass,
    required this.artisanHallmark,
    required this.internalBobbinCapacity,
    required this.threadDeliveryEyelet,
    required this.timberHardwood,
    required this.tipMetallurgy,
    required this.physicalProportions,
    required this.trackFrictionWear,
    required this.weavingGroundZero,
    required this.temperatureRange,
    required this.era,
    required this.calibratedSite,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'shuttleRegistryMark': shuttleRegistryMark,
    'fiberType': fiberType.name,
    'loomApplicationClass': loomApplicationClass.name,
    'artisanHallmark': artisanHallmark,
    'internalBobbinCapacity': internalBobbinCapacity,
    'threadDeliveryEyelet': threadDeliveryEyelet.name,
    'timberHardwood': timberHardwood.name,
    'tipMetallurgy': tipMetallurgy.name,
    'physicalProportions': physicalProportions,
    'trackFrictionWear': trackFrictionWear.name,
    'weavingGroundZero': weavingGroundZero,
    'temperatureRange': temperatureRange,
    'era': era,
    'calibratedSite': calibratedSite,
    'notes': notes,
    'photoPath': photoPath,
    'tags': tags,
    'dateAdded': dateAdded.toIso8601String(),
  };

  factory WeavingShuttleModel.fromJson(Map<String, dynamic> json) {
    return WeavingShuttleModel(
      id: json['id'] ?? '',
      shuttleRegistryMark: json['shuttleRegistryMark'] ?? '',
      fiberType:
          FiberType.values.asNameMap()[json['fiberType']] ?? FiberType.cotton,
      loomApplicationClass:
          LoomApplicationClass.values
              .asNameMap()[json['loomApplicationClass']] ??
          LoomApplicationClass.handLoomFly,
      artisanHallmark: _parseArtisanHallmark(json['artisanHallmark']),
      internalBobbinCapacity: json['internalBobbinCapacity'] ?? '',
      threadDeliveryEyelet:
          ThreadDeliveryEyelet.values
              .asNameMap()[json['threadDeliveryEyelet']] ??
          ThreadDeliveryEyelet.notApplicable,
      timberHardwood:
          TimberHardwood.values.asNameMap()[json['timberHardwood']] ??
          TimberHardwood.seasonedPersimmon,
      tipMetallurgy:
          TipMetallurgy.values.asNameMap()[json['tipMetallurgy']] ??
          TipMetallurgy.hardenedToolSteel,
      physicalProportions: json['physicalProportions'] ?? '',
      trackFrictionWear:
          TrackFrictionWear.values.asNameMap()[json['trackFrictionWear']] ??
          TrackFrictionWear.lightTrackPolish,
      weavingGroundZero: json['weavingGroundZero'] ?? '',
      temperatureRange: json['temperatureRange'] ?? '',
      era: json['era'] ?? '',
      calibratedSite: json['calibratedSite'] ?? '',
      notes: json['notes'] ?? '',
      photoPath: json['photoPath'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
    );
  }
}

String _parseArtisanHallmark(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  if (text.isEmpty) return '';
  final enumMatch = ArtisanHallmark.values.asNameMap()[text];
  return enumMatch?.label ?? text;
}
