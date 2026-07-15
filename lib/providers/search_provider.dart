import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttles_of_the_mill_row/models/project_model.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<WeavingShuttleModel> filteredList(List<WeavingShuttleModel> list) {
    final query = searchQuery.toLowerCase().trim();
    if (query.isEmpty) return list;
    return list.where((item) {
      return item.shuttleRegistryMark.toLowerCase().contains(query) ||
          item.artisanHallmark.toLowerCase().contains(query) ||
          item.weavingGroundZero.toLowerCase().contains(query) ||
          item.calibratedSite.toLowerCase().contains(query) ||
          item.era.toLowerCase().contains(query) ||
          item.loomApplicationClass.label.toLowerCase().contains(query) ||
          item.timberHardwood.label.toLowerCase().contains(query) ||
          item.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
