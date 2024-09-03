import 'dart:async';

import 'package:universal_io/io.dart';

import 'base_socket.dart';

class XMPPSocket extends XMPPSocketBase {
  @override
  void close() {
    // TODO: implement close
  }

  @override
  Future<XMPPSocket> connect<S>(dynamic host, int port) {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  StreamSubscription<String> listen(void Function(String event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // TODO: implement listen
    throw UnimplementedError();
  }

  @override
  void write(Object? message) {
    // TODO: implement write
    throw UnimplementedError();
  }

  @override
  Future<SecureSocket?> secure({
    host,
    SecurityContext? context,
    bool Function(X509Certificate certificate)? onBadCertificate,
    List<String>? supportedProtocols,
  }) {
    // TODO: implement secure
    throw UnimplementedError();
  }
}
