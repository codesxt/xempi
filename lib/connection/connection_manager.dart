import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:xempi/helpers/message_helper.dart';
import 'package:xml/xml.dart';

import '../data/account_settings.dart';
import '../data/connection_settings.dart';
import '../socket_api/stub_implementation.dart'
    if (dart.library.io) '../socket_api/socket_implementation.dart'
    if (dart.library.html) '../socket_api/websocket_implementation.dart';

class XempiConnectionManager {
  XempiAccountSettings accountSettings;
  XempiConnectionSettings connectionSettings;
  Function(XempiConnectionManager)? onConnectionAvailable;
  late XMPPSocket _socket;

  StreamController<XmlDocument> inboundMessages =
      StreamController<XmlDocument>.broadcast();
  StreamController<XmlDocument> outboundMessages =
      StreamController<XmlDocument>.broadcast();
  StreamController<XmlDocument> inboundIqStanzas =
      StreamController<XmlDocument>.broadcast();

  XempiConnectionManager({
    required this.accountSettings,
    required this.connectionSettings,
    this.onConnectionAvailable,
  });

  void connect() async {
    XMPPSocket socket = XMPPSocket();
    debugPrint('[Xempi] Connecting to socket...');

    _socket = await socket.connect(
      connectionSettings.host,
      connectionSettings.port,
    );

    inboundMessages.stream.listen(_onInboundMessage);

    socket.listen(_handleSocketResponse, onDone: () {
      debugPrint('Socket done');
    }, onError: (Object error, StackTrace stackTrace) {
      debugPrint('On error');
    });

    sendOpeningMessage();
  }

  /// Called every time the server sends an XML message through
  /// the current stream.
  _onInboundMessage(XmlDocument document) async {
    // Check if document contains an 'iq' XmlElement and adds it to
    // its respective stream.
    if (document.rootElement.name.toString() == 'iq') {
      inboundIqStanzas.add(document);
    }

    // Check if it is an opening message
    XmlElement? streamElement = document.getElement('stream:stream');
    if (streamElement != null) {
      // Check if there are stream:features elements defined
      List<XmlElement> elems =
          streamElement.childElements.where((XmlElement e) {
        return e.name.toString() == 'stream:features';
      }).toList();
      if (elems.isNotEmpty) {
        XmlElement streamFeatures = elems.first;
        inboundMessages.add(XmlDocument.parse(streamFeatures.toXmlString()));
      }
    }

    if (document.rootElement.name.toString() == 'proceed' &&
        document.rootElement.getAttribute('xmlns') ==
            'urn:ietf:params:xml:ns:xmpp-tls') {
      SecureSocket? secureSocket = await _socket.secure();
      if (secureSocket != null) {
        secureSocket
            .cast<List<int>>()
            .transform(utf8.decoder)
            .listen(_handleSocketResponse);
        sendOpeningMessage();
      }
    }

    if (document.rootElement.name.toString() == 'stream:features') {
      // <response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'></response>
      // TODO: Verificar si permite authorization
      // Check all the stream features reported from the server
      // and act accordingly.
      document.firstChild!.childElements.toList().forEach((XmlElement element) {
        debugPrint('ELEMENT NAME');
        debugPrint(element.name.toString());
        // If starttls is required, acknowledge and start process
        if (element.name.toString() == 'starttls' &&
            element.getAttribute('xmlns') ==
                'urn:ietf:params:xml:ns:xmpp-tls') {
          if (element.getElement('required') != null) {
            XmlDocument starttlsResponse =
                XempiMessageHelper.buildStartTlsResponse();
            debugPrint(starttlsResponse.toXmlString());
            _socket.write(starttlsResponse.toXmlString());
          }
        }

        if (element.name.toString() == 'mechanisms') {
          XmlDocument doc = XempiMessageHelper.buildSaslPlainAuthMessage(
            connectionSettings: connectionSettings,
            accountSettings: accountSettings,
          );
          writeDocumentToSocket(doc);
        }

        if (element.name.toString() == 'bind') {
          XmlDocument iqBindResource = XempiMessageHelper.buildIqBindResource(
            connectionSettings: connectionSettings,
            accountSettings: accountSettings,
          );
          writeDocumentToSocket(iqBindResource);
        }

        if (element.name.toString() == 'session') {
          XmlDocument iqStartSession = XempiMessageHelper.buildIqStartSession(
            connectionSettings: connectionSettings,
            accountSettings: accountSettings,
          );
          writeDocumentToSocket(iqStartSession);

          XmlDocument iqDiscoInfo = XempiMessageHelper.buildIqDiscoInfo(
            connectionSettings: connectionSettings,
            accountSettings: accountSettings,
          );
          writeDocumentToSocket(iqDiscoInfo);

          onConnectionAvailable?.call(this);
        }
      });
    }

    if (document.rootElement.name.toString() == 'success' &&
        document.rootElement.getAttribute('xmlns') ==
            'urn:ietf:params:xml:ns:xmpp-sasl') {
      debugPrint('Successful Plain SASL Authentication');
      // At this point, the client should send another initial stream header
      // as described per RFC 6120 6.4.6. SASL Success:
      //
      //  Upon receiving the <success/> element, the initiating entity MUST
      //  initiate a new stream over the existing TCP connection by sending a
      //  new initial stream header to the receiving entity (as specified under
      //  Section 4.3.3, the initiating entity MUST NOT send a closing
      //  </stream> tag before sending the new initial stream header, since the
      //  receiving entity and initiating entity MUST consider the original
      //  stream to be replaced upon success of the SASL negotiation).
      sendOpeningMessage();
    }
    debugPrint('\n${document.toXmlString(pretty: true)}');
  }

  void _handleSocketResponse(String data) {
    debugPrint('>> Message from socket:');
    debugPrint(data);

    if (data == '</stream:stream>') {
      debugPrint('Connection ended');
      return;
    }

    // Checks if the message closes the stream. The </stream:stream>
    // is received when the server closes the XML message stream, usually
    // in case of an error.
    // This function removes the trailing </stream:stream> so it can be
    // properly parsed.
    // It is important to handle errors or interruptions here anyway.
    if (data.endsWith('</stream:stream>')) {
      data = data.substring(0, data.length - 16);
      // Handle XMPP errors reported by the server here ↯
    }

    // Adds </stream:stream> at the end of the initial message so it can be
    // properly parsed. This is only added to make the XML element parseable
    // but is not part of the protocol. The proper way to send the
    // </stream:stream> element is at the end of the connection to close
    // the stream.
    // Check RFC3921 3. Session Establishment for reference.
    if (data.startsWith('<stream:stream') ||
        data.startsWith('<?xml version=\'1.0\'?><stream:stream')) {
      data += '</stream:stream>';
    }

    debugPrint('>>> Mensaje parseado:');
    XmlDocument document = XmlDocument.parse(data);
    inboundMessages.add(document);
  }

  writeDocumentToSocket(XmlDocument document) {
    debugPrint('>> Written to server:');
    debugPrint(document.toXmlString(pretty: true));
    outboundMessages.add(document);
    _socket.write(document.toXmlString());
  }

  writeStringToSocket(String document) {
    debugPrint('>> Written to server:');
    debugPrint(document);
    _socket.write(document);
  }

  sendOpeningMessage() {
    if (kIsWeb) {
      XmlDocument websocketOpening =
          XempiMessageHelper.buildWebsocketOpeningMessage(
        connectionSettings: connectionSettings,
        accountSettings: accountSettings,
      );
      writeDocumentToSocket(websocketOpening);
    } else {
      XmlDocument document = XempiMessageHelper.buildOpeningMessage(
        connectionSettings: connectionSettings,
        accountSettings: accountSettings,
      );
      String message = document.toXmlString(
        pretty: true,
      );

      // Remove closing trailing message "\" so the XML stream stays open
      // Check RFC3921 3. Session Establishment for reference.
      int positionToDelete = message.length - 2;
      message = message.substring(0, positionToDelete) +
          message.substring(positionToDelete + 1);

      writeStringToSocket(message);
    }
  }

  /// Sends an 'iq' [XmlDocument] that can be awaited by subscribing to the
  /// [inboundIqStanzas] stream and checking if a response with the same
  /// id has been received.
  Future<XmlDocument> sendAwaitableIq(XmlDocument document) async {
    XmlElement root = document.rootElement;
    String name = root.name.toString();
    if (name != 'iq') {
      throw ArgumentError('XmlDocument must contain an \'iq\' element.');
    }
    String? requestId = root.getAttribute('id');
    if (requestId == null) {
      throw ArgumentError('XmlDocument root must contain an \'id\' attribute.');
    }
    writeDocumentToSocket(document);
    await for (final XmlDocument xmlDocument in inboundIqStanzas.stream) {
      String? responseId = xmlDocument.rootElement.getAttribute('id');
      if (requestId == responseId) {
        return xmlDocument;
      }
    }
    throw TimeoutException('An adequate iq response could not be received');
  }
}
