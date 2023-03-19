import 'package:crypto/crypto.dart';

import 'harvester_isolate.dart' show HarvesterIsolate;

/// Represents a central [Set] of [HarvesterIsolate] objects.
class HarvesterIsolateSet {
  final Set<HarvesterIsolate> _set = {};

  /// Gets a [HarvesterIsolate] from the set that matches the [Digest] provided. Can be [null] if not found.
  HarvesterIsolate? get(Digest hash) {
    return _set.where((e) => e.hash == hash).toList()[0];
  }

  /// Appends a [HarvesterIsolate] to the set if a [Digest] if it does not exist already.
  void add(HarvesterIsolate isolate) {
    if (get(isolate.hash) != null) {
      _set.add(isolate);
    }
  }
}
