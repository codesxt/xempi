import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:xempi/xempi.dart';

import 'mock_xmpp_server.dart/mock_xmpp_server.dart';

void main() {
  group('MockXmppServer Tests', () {
    late MockXmppServer mockServer;

    setUp(() async {
      mockServer = MockXmppServer();
      await mockServer.serve();
    });

    tearDown(() async {
      await mockServer.stop();
    });

    test('Client can connect and send data', () async {
      XempiAccountSettings accountSettings = XempiAccountSettings(
        jid: XempiJid(
          localPart: 'exampleuser',
          domainPart: 'exampleserver.com',
          resourcePart: 'exampleresource',
        ),
        password: '**********',
      );
      XempiConnectionSettings connectionSettings = XempiConnectionSettings(
        host: '127.0.0.1',
        port: 5222,
      );
      XempiConnectionManager connectionManager = XempiConnectionManager(
        accountSettings: accountSettings,
        connectionSettings: connectionSettings,
      );
      connectionManager.connect();

      final completer = Completer();
      XmlDocument? response;
      connectionManager.inboundMessages.stream.listen((XmlDocument document) {
        response = document;
        completer.complete();
      });
      await completer.future.timeout(const Duration(seconds: 5));
      expect(response, isNotNull);
    });
  });
}
