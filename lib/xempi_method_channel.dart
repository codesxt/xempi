import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'xempi_platform_interface.dart';

/// An implementation of [XempiPlatform] that uses method channels.
class MethodChannelXempi extends XempiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xempi');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
