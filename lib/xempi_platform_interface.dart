import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'xempi_method_channel.dart';

abstract class XempiPlatform extends PlatformInterface {
  /// Constructs a XempiPlatform.
  XempiPlatform() : super(token: _token);

  static final Object _token = Object();

  static XempiPlatform _instance = MethodChannelXempi();

  /// The default instance of [XempiPlatform] to use.
  ///
  /// Defaults to [MethodChannelXempi].
  static XempiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XempiPlatform] when
  /// they register themselves.
  static set instance(XempiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
