import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttles_of_the_mill_row/models/project_model.dart';
import 'package:shuttles_of_the_mill_row/providers/image_provider.dart';
import 'package:shuttles_of_the_mill_row/providers/input_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<WeavingShuttleModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'smr_weaving_shuttles_v1';
  final _uuid = const Uuid();
  final _random = Random();

  void _sortEntries() =>
      entries.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

  String _generateRegistryMark(InputNotifier p) {
    final fiber = p.fiberType.label.substring(0, 3).toUpperCase();
    final classToken = p.loomApplicationClass.label.split(' ').last;
    final suffix = classToken.substring(0, 1).toUpperCase();
    final numeric = (1000 + _random.nextInt(9000)).toString();
    return 'SMR-LOOM-$numeric-$fiber-$suffix';
  }

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        entries = (jsonDecode(jsonString) as List<dynamic>)
            .map((item) => WeavingShuttleModel.fromJson(item))
            .toList();
        _sortEntries();
      }
    } catch (e) {
      debugPrint('Error loading weaving shuttles: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  WeavingShuttleModel _fromInput(
    WidgetRef ref, {
    WeavingShuttleModel? existing,
  }) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    return WeavingShuttleModel(
      id: existing?.id ?? _uuid.v4(),
      shuttleRegistryMark:
          existing?.shuttleRegistryMark ?? _generateRegistryMark(p),
      fiberType: p.fiberType,
      loomApplicationClass: p.loomApplicationClass,
      artisanHallmark: p.artisanHallmark,
      internalBobbinCapacity: p.internalBobbinCapacity,
      threadDeliveryEyelet: p.threadDeliveryEyelet,
      timberHardwood: p.timberHardwood,
      tipMetallurgy: p.tipMetallurgy,
      physicalProportions: p.physicalProportions,
      trackFrictionWear: p.trackFrictionWear,
      weavingGroundZero: p.weavingGroundZero,
      temperatureRange: p.temperatureRange,
      era: p.era,
      calibratedSite: p.calibratedSite,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty
          ? imgProv.resultImage
          : (existing?.photoPath ?? p.photoPath),
      tags: List<String>.from(p.tags),
      dateAdded: existing?.dateAdded ?? DateTime.now(),
    );
  }

  void addEntry(WidgetRef ref) {
    entries = [_fromInput(ref), ...entries];
    _sortEntries();
    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final newList = List<WeavingShuttleModel>.from(entries);
    newList[index] = _fromInput(ref, existing: entries[index]);
    entries = newList;
    _sortEntries();
    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    final newList = List<WeavingShuttleModel>.from(entries)..removeAt(index);
    entries = newList;
    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];
    p.shuttleRegistryMark = entry.shuttleRegistryMark;
    p.fiberType = entry.fiberType;
    p.loomApplicationClass = entry.loomApplicationClass;
    p.artisanHallmark = entry.artisanHallmark;
    p.internalBobbinCapacity = entry.internalBobbinCapacity;
    p.threadDeliveryEyelet = entry.threadDeliveryEyelet;
    p.timberHardwood = entry.timberHardwood;
    p.tipMetallurgy = entry.tipMetallurgy;
    p.physicalProportions = entry.physicalProportions;
    p.trackFrictionWear = entry.trackFrictionWear;
    p.weavingGroundZero = entry.weavingGroundZero;
    p.temperatureRange = entry.temperatureRange;
    p.era = entry.era;
    p.calibratedSite = entry.calibratedSite;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;
    imgProv.resultImage = entry.photoPath;
    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
