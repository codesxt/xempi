import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:xempi/xempi.dart';

class MockXmppServer {
  ServerSocket? _server;

  Future<void> serve() async {
    _server = await ServerSocket.bind(
      '127.0.0.1',
      5222,
    );
    _server!.listen(
      (socket) {
        socket.listen((Uint8List data) {
          String xmlString = utf8.decode(data);
          if (xmlString.contains('<stream:stream')) {
            xmlString += '</stream:stream>';
          }
          XmlDocument document = XmlDocument.parse(xmlString);
          _handleDocument(socket, document);
          socket.write('');
        });
      },
      onDone: () {},
      onError: (Object error, StackTrace stacktrace) {},
      cancelOnError: true,
    );
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
    }
  }

  void _handleDocument(Socket socket, XmlDocument document) async {
    XmlElement rootElement = document.rootElement;
    String name = rootElement.name.toString();

    if (name == 'stream:stream') {
      String to = rootElement.getAttribute('from') ?? '';
      final builder = XmlBuilder();
      builder.processing('xml', 'version="1.0"');
      builder.element(
        'stream:stream',
        attributes: {
          'xmlns': 'jabber:client',
          'version': '1.0',
          'xmlns:stream': 'http://etherx.jabber.org/streams',
          'from': 'xmpp.mock.server',
          'to': to,
          'xml:lang': 'en',
        },
      );
      XmlDocument document = builder.buildDocument();
      socket.write(document.toXmlString());
    }
  }
}
