import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttles_of_the_mill_row/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _shuttleRegistryMark = '';
  FiberType _fiberType = FiberType.cotton;
  LoomApplicationClass _loomApplicationClass = LoomApplicationClass.handLoomFly;
  String _artisanHallmark = '';
  String _internalBobbinCapacity = '';
  ThreadDeliveryEyelet _threadDeliveryEyelet =
      ThreadDeliveryEyelet.notApplicable;
  TimberHardwood _timberHardwood = TimberHardwood.seasonedPersimmon;
  TipMetallurgy _tipMetallurgy = TipMetallurgy.hardenedToolSteel;
  String _physicalProportions = '';
  TrackFrictionWear _trackFrictionWear = TrackFrictionWear.lightTrackPolish;
  String _weavingGroundZero = '';
  String _temperatureRange = '';
  String _era = '';
  String _calibratedSite = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get shuttleRegistryMark => _shuttleRegistryMark;
  FiberType get fiberType => _fiberType;
  LoomApplicationClass get loomApplicationClass => _loomApplicationClass;
  String get artisanHallmark => _artisanHallmark;
  String get internalBobbinCapacity => _internalBobbinCapacity;
  ThreadDeliveryEyelet get threadDeliveryEyelet => _threadDeliveryEyelet;
  TimberHardwood get timberHardwood => _timberHardwood;
  TipMetallurgy get tipMetallurgy => _tipMetallurgy;
  String get physicalProportions => _physicalProportions;
  TrackFrictionWear get trackFrictionWear => _trackFrictionWear;
  String get weavingGroundZero => _weavingGroundZero;
  String get temperatureRange => _temperatureRange;
  String get era => _era;
  String get calibratedSite => _calibratedSite;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set shuttleRegistryMark(String v) {
    _shuttleRegistryMark = v;
    notifyListeners();
  }

  set fiberType(FiberType v) {
    _fiberType = v;
    notifyListeners();
  }

  set loomApplicationClass(LoomApplicationClass v) {
    _loomApplicationClass = v;
    notifyListeners();
  }

  set artisanHallmark(String v) {
    _artisanHallmark = v;
    notifyListeners();
  }

  set internalBobbinCapacity(String v) {
    _internalBobbinCapacity = v;
    notifyListeners();
  }

  set threadDeliveryEyelet(ThreadDeliveryEyelet v) {
    _threadDeliveryEyelet = v;
    notifyListeners();
  }

  set timberHardwood(TimberHardwood v) {
    _timberHardwood = v;
    notifyListeners();
  }

  set tipMetallurgy(TipMetallurgy v) {
    _tipMetallurgy = v;
    notifyListeners();
  }

  set physicalProportions(String v) {
    _physicalProportions = v;
    notifyListeners();
  }

  set trackFrictionWear(TrackFrictionWear v) {
    _trackFrictionWear = v;
    notifyListeners();
  }

  set weavingGroundZero(String v) {
    _weavingGroundZero = v;
    notifyListeners();
  }

  set temperatureRange(String v) {
    _temperatureRange = v;
    notifyListeners();
  }

  set era(String v) {
    _era = v;
    notifyListeners();
  }

  set calibratedSite(String v) {
    _calibratedSite = v;
    notifyListeners();
  }

  set notes(String v) {
    _notes = v;
    notifyListeners();
  }

  set photoPath(String v) {
    _photoPath = v;
    notifyListeners();
  }

  set tags(List<String> v) {
    _tags = v;
    notifyListeners();
  }

  set dateAdded(DateTime v) {
    _dateAdded = v;
    notifyListeners();
  }

  void clearAll() {
    _shuttleRegistryMark = '';
    _fiberType = FiberType.cotton;
    _loomApplicationClass = LoomApplicationClass.handLoomFly;
    _artisanHallmark = '';
    _internalBobbinCapacity = '';
    _threadDeliveryEyelet = ThreadDeliveryEyelet.notApplicable;
    _timberHardwood = TimberHardwood.seasonedPersimmon;
    _tipMetallurgy = TipMetallurgy.hardenedToolSteel;
    _physicalProportions = '';
    _trackFrictionWear = TrackFrictionWear.lightTrackPolish;
    _weavingGroundZero = '';
    _temperatureRange = '';
    _era = '';
    _calibratedSite = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
