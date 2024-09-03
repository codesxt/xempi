import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'base_socket.dart';

class XMPPSocket extends XMPPSocketBase {
  Socket? _socket;

  @override
  Future<XMPPSocket> connect<S>(dynamic host, int port) async {
    Socket socket = await Socket.connect(host, port);
    _socket = socket;

    return Future.value(this);
  }

  @override
  StreamSubscription<String> listen(
    void Function(String event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (_socket == null) throw Exception('Socket not connected.');
    return _socket!
        .cast<List<int>>()
        .transform(
          utf8.decoder,
        )
        .listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  @override
  void write(Object? message) {
    _socket?.write(message);
  }

  @override
  void close() {
    _socket?.close();
  }

  @override
  Future<SecureSocket?> secure({
    host,
    SecurityContext? context,
    bool Function(X509Certificate certificate)? onBadCertificate,
    List<String>? supportedProtocols,
  }) async {
    SecureSocket socket = await SecureSocket.secure(
      _socket!,
      context: context,
      onBadCertificate: onBadCertificate,
      supportedProtocols: supportedProtocols,
    );
    _socket = socket;
    return socket;
  }
}
