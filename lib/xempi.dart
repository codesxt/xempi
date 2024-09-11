import 'xempi_platform_interface.dart';

import 'socket_api/stub_implementation.dart'
    if (dart.library.io) './socket_api/socket_implementation.dart'
    if (dart.library.html) './socket_api/websocket_implementation.dart';

export 'data/jid.dart';
export 'connection/connection_manager.dart';
export 'data/account_settings.dart';
export 'data/connection_settings.dart';
export 'data/logging_settings.dart';
export 'helpers/message_helper.dart';

export 'package:xml/xml.dart';

class Xempi {
  Future<String?> getPlatformVersion() {
    return XempiPlatform.instance.getPlatformVersion();
  }

  void createConnection() {
    XMPPSocket();
  }
}
