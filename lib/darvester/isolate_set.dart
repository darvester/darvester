import 'package:crypto/crypto.dart';

import 'harvester_isolate.dart' show HarvesterIsolate;

/// Represents a central [Set] of [HarvesterIsolate] objects.
class HarvesterIsolateSet {
  final Set<HarvesterIsolate> set = {};

  HarvesterIsolateSet._privateConstructor();

  static final HarvesterIsolateSet instance = HarvesterIsolateSet._privateConstructor();

  /// Gets a [HarvesterIsolate] from the set that matches the [Digest] provided. Can be [null] if not found.
  HarvesterIsolate? get(Digest hash) {
    if (set.isNotEmpty) {
      List<HarvesterIsolate?> results = set.where((e) => e.hash == hash).toList();
      return results.isNotEmpty ? results[0] : null;
    }
    return null;
  }

  /// Appends a [HarvesterIsolate] to the set if a [Digest] if it does not exist already.
  void add(HarvesterIsolate isolate) {
    if (get(isolate.hash) == null) {
      set.add(isolate);
    }
  }
}
