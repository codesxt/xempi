import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:universal_io/io.dart';
import 'package:xempi/data/logging_settings.dart';
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
  XempiLoggingSettings loggingSettings;
  Function(XempiConnectionManager)? onConnectionAvailable;
  XMPPSocket? _socket;

  Logger logger = Logger(
    filter: null,
    printer: PrettyPrinter(
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: null,
  );

  /// [StreamController] to broadcast all incoming messages through
  /// the open connection.
  StreamController<XmlDocument> inboundMessages =
      StreamController<XmlDocument>.broadcast();

  /// [StreamController] to broadcast all outgoing messages through
  /// the open connection.
  StreamController<XmlDocument> outboundMessages =
      StreamController<XmlDocument>.broadcast();

  /// [StreamController] to broadcast all incoming 'iq' stanzas through
  /// the open connection.
  StreamController<XmlDocument> inboundIqStanzas =
      StreamController<XmlDocument>.broadcast();

  /// [StreamController] to broadcast all outgoing 'iq' stanzas through
  /// the open connection.
  StreamController<XmlDocument> outboundIqStanzas =
      StreamController<XmlDocument>.broadcast();

  /// [StreamController] to broadcast all incoming 'presence' stanzas through
  /// the open connection.
  StreamController<XmlDocument> inboundPresenceStanzas =
      StreamController<XmlDocument>.broadcast();

  /// [StreamController] to broadcast all outgoing 'presence' stanzas through
  /// the open connection.
  StreamController<XmlDocument> outboundPresenceStanzas =
      StreamController<XmlDocument>.broadcast();

  /// [StreamController] to broadcast all incoming 'message' stanzas through
  /// the open connection.
  StreamController<XmlDocument> inboundMessageStanzas =
      StreamController<XmlDocument>.broadcast();

  /// [StreamController] to broadcast all outgoing 'message' stanzas through
  /// the open connection.
  StreamController<XmlDocument> outboundMessageStanzas =
      StreamController<XmlDocument>.broadcast();

  XempiConnectionManager({
    required this.accountSettings,
    required this.connectionSettings,
    this.onConnectionAvailable,
    this.loggingSettings = const XempiLoggingSettings.all(),
  });

  void connect() async {
    XMPPSocket socket = XMPPSocket();
    debugPrint('[Xempi] Connecting to socket...');

    // TODO: Add specific settings for the web version
    _socket = await socket.connect(
      connectionSettings.host,
      connectionSettings.port,
    );

    inboundMessages.stream.listen(_onInboundMessage);

    inboundPresenceStanzas.stream.listen(_onInboundPressenceStanza);
    outboundPresenceStanzas.stream.listen(_onOutboundPressenceStanza);
    inboundMessageStanzas.stream.listen(_onInboundMessageStanza);
    outboundMessageStanzas.stream.listen(_onOutboundMessageStanza);
    inboundIqStanzas.stream.listen(_onInboundIqStanza);
    outboundIqStanzas.stream.listen(_onOutboundIqStanza);

    socket.listen(
      _handleSocketResponse,
      onDone: () {
        // TODO: Enable callback to be defined for socket end
        debugPrint('Socket done');
      },
      onError: (Object error, StackTrace stackTrace) {
        // TODO: Enable callback to be defined for socket error
        // TODO: Also add callback for XMPP error messages
        // Consider 4.9.1.1.  Stream Errors Are Unrecoverable
        debugPrint('On error');
      },
      cancelOnError: false,
    );

    sendOpeningMessage();
  }

  void disconnect() {
    inboundMessages.close();

    inboundPresenceStanzas.close();
    outboundPresenceStanzas.close();
    inboundMessageStanzas.close();
    outboundMessageStanzas.close();
    inboundIqStanzas.close();
    outboundIqStanzas.close();

    // TODO: Close stream with pretty message
    _socket?.close();
    _socket = null;
  }

  /// Called every time the server sends an XML message through
  /// the current stream.
  _onInboundMessage(XmlDocument document) async {
    // Check if document contains an 'iq' XmlElement and adds it to
    // its respective stream.
    if (document.rootElement.name.toString() == 'iq') {
      inboundIqStanzas.add(document);
    }
    // Check if document contains an 'presence' XmlElement and adds it to
    // its respective stream.
    if (document.rootElement.name.toString() == 'presence') {
      inboundPresenceStanzas.add(document);
    }
    // Check if document contains an 'message' XmlElement and adds it to
    // its respective stream.
    if (document.rootElement.name.toString() == 'message') {
      inboundMessageStanzas.add(document);
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

    // Upgrades socket to secure socket if TLS negotiation is authorized
    // by a "proceed" message.
    if (document.rootElement.name.toString() == 'proceed' &&
        document.rootElement.getAttribute('xmlns') ==
            'urn:ietf:params:xml:ns:xmpp-tls') {
      SecureSocket? secureSocket = await _socket?.secure();
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
        // If starttls is required, acknowledge and start process
        if (element.name.toString() == 'starttls' &&
            element.getAttribute('xmlns') ==
                'urn:ietf:params:xml:ns:xmpp-tls') {
          if (element.getElement('required') != null) {
            XmlDocument starttlsResponse =
                XempiMessageHelper.buildStartTlsResponse();
            debugPrint(starttlsResponse.toXmlString());
            _socket?.write(starttlsResponse.toXmlString());
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
  }

  /// Called everytime the XMPP socket receives
  /// a new message.
  void _handleSocketResponse(String data) {
    // If the server closes the connection, a "</stream:stream>"
    // closing tag is received through the socket.
    if (data == '</stream:stream>') {
      debugPrint('Connection ended');
      return;
    }

    // Checks if the message closes the stream but also includes another message.
    // The </stream:stream> is received when the server closes the XML
    // message stream, usually in case of an error.
    // This function removes the trailing </stream:stream> so it can be
    // properly parsed.
    // It is important to handle errors or interruptions here anyway.
    if (data.endsWith('</stream:stream>')) {
      data = data.substring(0, data.length - 16);
      // TODO: Handle XMPP errors reported by the server here ↯
      // Or maybe they should be managed in the inbound messages callback?
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

    XmlDocument document = XmlDocument.parse(data);
    inboundMessages.add(document);
  }

  writeDocumentToSocket(XmlDocument document) {
    outboundMessages.add(document);

    if (document.rootElement.name.toString() == 'iq') {
      outboundIqStanzas.add(document);
    }
    if (document.rootElement.name.toString() == 'presence') {
      outboundPresenceStanzas.add(document);
    }
    if (document.rootElement.name.toString() == 'message') {
      outboundMessageStanzas.add(document);
    }
    _socket?.write(document.toXmlString());
  }

  writeStringToSocket(String document) {
    debugPrint('[Xempi] String written to server:');
    debugPrint(document);
    _socket?.write(document);
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

  void _onInboundPressenceStanza(XmlDocument document) {
    const String name = 'presence';
    if (document.rootElement.name.toString() == name) {
      if (loggingSettings.inboundPresenceStanzas) {
        logMessage(document, header: '[➡️ Inbound presence Stanza]');
      }
    }
  }

  void _onOutboundPressenceStanza(XmlDocument document) {
    const String name = 'presence';
    if (document.rootElement.name.toString() == name) {
      if (loggingSettings.outboundPresenceStanzas) {
        logMessage(document, header: '[⬅️ Outbound presence Stanza]');
      }
    }
  }

  void _onInboundMessageStanza(XmlDocument document) {
    const String name = 'message';
    if (document.rootElement.name.toString() == name) {
      if (loggingSettings.inboundMessageStanzas) {
        logMessage(document, header: '[➡️ Inbound message Stanza]');
      }
    }
  }

  void _onOutboundMessageStanza(XmlDocument document) {
    const String name = 'message';
    if (document.rootElement.name.toString() == name) {
      if (loggingSettings.outboundMessageStanzas) {
        logMessage(document, header: '[⬅️ Outbound message Stanza]');
      }
    }
  }

  void _onInboundIqStanza(XmlDocument document) {
    const String name = 'iq';
    if (document.rootElement.name.toString() == name) {
      if (loggingSettings.inboundIqStanzas) {
        logMessage(document, header: '[➡️ Inbound iq Stanza]');
      }
    }
  }

  void _onOutboundIqStanza(XmlDocument document) {
    const String name = 'iq';
    if (document.rootElement.name.toString() == name) {
      if (loggingSettings.outboundIqStanzas) {
        logMessage(document, header: '[⬅️ Outbound iq Stanza]');
      }
    }
  }

  void logMessage(XmlDocument document, {String header = ''}) {
    String message = document.toXmlString(pretty: true);
    if (header.isNotEmpty) {
      message = '$header\n$message';
    }
    logger.d(message);
  }
}

// TODO: Add callbacks for the different listeners
// TODO: Call logMessage in the listeners according to the loggingSettings
