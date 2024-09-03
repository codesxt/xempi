import 'dart:async';

import 'package:universal_io/io.dart';

import 'base_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class XMPPSocket extends XMPPSocketBase {
  WebSocketChannel? _socket;

  @override
  Future<XMPPSocket> connect<S>(
    dynamic host,
    int port, {
    String? path = 'ws',
    String? scheme = 'wss',
    String Function(String event)? map,
  }) {
    Uri uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: path,
    );
    _socket = WebSocketChannel.connect(
      uri,
      protocols: ['xmpp'],
    );

    return Future.value(this);
  }

  @override
  StreamSubscription<String> listen(
    void Function(String event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _socket!.stream.map((event) => event.toString()).listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  @override
  void write(Object? message) {
    _socket?.sink.add(message);
  }

  @override
  void close() {
    _socket?.sink.close();
  }

  @override
  Future<SecureSocket?> secure({
    host,
    SecurityContext? context,
    bool Function(X509Certificate certificate)? onBadCertificate,
    List<String>? supportedProtocols,
  }) {
    return Future.value(null);
  }
}
