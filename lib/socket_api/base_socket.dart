import 'package:universal_io/io.dart';

/// Abstract class used to define a generic Socket implementation
/// to use later for Sockets and Websockets respectively
abstract class XMPPSocketBase extends Stream<String> {
  // factory XMPPSocket() => getInstance();

  /// Create initial socket connection and return itself.
  Future<XMPPSocketBase> connect<S>(dynamic host, int port);

  /// Write a message to the socket stream.
  void write(Object? message);

  /// Close connection
  void close();

  Future<SecureSocket?> secure({
    host,
    SecurityContext? context,
    bool Function(X509Certificate certificate)? onBadCertificate,
    List<String>? supportedProtocols,
  });
}
