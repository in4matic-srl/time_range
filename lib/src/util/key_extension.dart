import 'package:flutter/foundation.dart';

extension KeyExtension on Key {
  String get value {
    if (this is ValueKey) {
      return (this as ValueKey).value.toString();
    } else {
      return toString();
    }
  }

  ValueKey<String> withSuffix(String suffix) {
    return ValueKey<String>('$value$suffix');
  }
}
