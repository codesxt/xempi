import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:xempi/xempi.dart';

part 'core.dart';
part 'chat_states.dart';
part 'message_retraction.dart';

class XempiMessageHelper {
  XempiMessageHelper._();

  // External libraries to implement specific messages.
  static XempiCoreHelper core = const XempiCoreHelper();
  static XempiChatStatesHelper chatStates = const XempiChatStatesHelper();
  static XempiMessageRetractionHelper messageRetraction =
      const XempiMessageRetractionHelper();

  // Getters to use as aliases for the implemented XEPs.
  static XempiChatStatesHelper get xep0085 => chatStates;
  static XempiMessageRetractionHelper get xep0424 => messageRetraction;

  static XmlDocument buildOpeningMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
  }) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element(
      'stream:stream',
      attributes: {
        'xmlns': 'jabber:client',
        'version': '1.0',
        'xmlns:stream': 'http://etherx.jabber.org/streams',
        'to': accountSettings.jid.domainPart,
        'xml:lang': 'en',
      },
    );
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument buildWebsocketOpeningMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
  }) {
    final builder = XmlBuilder();
    builder.element(
      'open',
      attributes: {
        'xmlns': 'urn:ietf:params:xml:ns:xmpp-framing',
        'version': '1.0',
        'xmlns:stream': 'http://etherx.jabber.org/streams',
        'to': accountSettings.jid.domainPart,
        'xml:lang': 'en',
      },
    );
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument buildIqFeatureDiscoveryMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
  }) {
    final builder = XmlBuilder();
    Uuid uuid = const Uuid();
    builder.element('iq', attributes: {
      'id': uuid.v4(),
      'type': 'get',
      'from': accountSettings.jid.toString(),
      'to': connectionSettings.host,
    }, nest: () {
      builder.element(
        'query',
        attributes: {
          'xmlns': 'http://jabber.org/protocol/disco#info',
        },
      );
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument buildStartTlsResponse() {
    final builder = XmlBuilder();
    builder.element('starttls', attributes: {
      'xmlns': 'urn:ietf:params:xml:ns:xmpp-tls',
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  /// https://www.rfc-editor.org/rfc/rfc4616
  static XmlDocument buildSaslPlainAuthMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
  }) {
    String authString =
        '${accountSettings.jid.localPart}@${accountSettings.jid.domainPart}\u0000${accountSettings.jid.localPart}\u0000${accountSettings.password}';

    Uint8List bytes = utf8.encode(authString);
    String base64Auth = base64.encode(bytes);
    final builder = XmlBuilder();
    builder.element('auth', attributes: {
      'xmlns': 'urn:ietf:params:xml:ns:xmpp-sasl',
      'mechanism': 'PLAIN',
    }, nest: () {
      builder.text(base64Auth);
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument buildIqBindResource({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
  }) {
    final builder = XmlBuilder();
    Uuid uuid = const Uuid();
    builder.element('iq', attributes: {
      'id': uuid.v4(),
      'type': 'set',
    }, nest: () {
      builder.element('bind', attributes: {
        'xmlns': 'urn:ietf:params:xml:ns:xmpp-bind',
      }, nest: () {
        builder.element('resource', nest: () {
          builder.text(accountSettings.jid.resourcePart);
        });
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument buildIqStartSession({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
  }) {
    final builder = XmlBuilder();
    Uuid uuid = const Uuid();
    builder.element('iq', attributes: {
      'id': uuid.v4(),
      'type': 'set',
      'to': connectionSettings.host,
    }, nest: () {
      builder.element('session', attributes: {
        'xmlns': 'urn:ietf:params:xml:ns:xmpp-session',
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument buildIqDiscoInfo({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
  }) {
    final builder = XmlBuilder();
    Uuid uuid = const Uuid();
    builder.element('iq', attributes: {
      'id': uuid.v4(),
      'type': 'get',
      'from': accountSettings.jid.toString(),
      'to': connectionSettings.host,
    }, nest: () {
      builder.element('query', attributes: {
        'xmlns': 'http://jabber.org/protocol/disco#info',
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument enableCarbons({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
  }) {
    final builder = XmlBuilder();
    Uuid uuid = const Uuid();
    builder.element('iq', attributes: {
      'xmlns': 'jabber:client',
      'from': accountSettings.jid.toString(),
      'id': uuid.v4(),
      'type': 'set',
    }, nest: () {
      builder.element('enable', attributes: {
        'xmlns': 'urn:xmpp:carbons:2',
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument mamRequest({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
    XempiJid? withJid,
    DateTime? start,
    DateTime? end,
    int? max,
    String? before,
    String? after,
  }) {
    final builder = XmlBuilder();
    Uuid uuid = const Uuid();
    builder.element('iq', attributes: {
      'xmlns': 'jabber:client',
      'from': accountSettings.jid.toString(),
      'id': uuid.v4(),
      'type': 'set',
    }, nest: () {
      builder.element('query', attributes: {
        'xmlns': 'urn:xmpp:mam:2',
      }, nest: () {
        builder.element(
          'x',
          attributes: {
            'xmlns': 'jabber:x:data',
            'type': 'submit',
          },
          nest: () {
            builder.element('field', attributes: {
              'var': 'FORM_TYPE',
              'type': 'hidden',
            }, nest: () {
              builder.element('value', nest: () {
                builder.text('urn:xmpp:mam:2');
              });
            });
            if (withJid != null) {
              builder.element('field', attributes: {
                'var': 'with',
              }, nest: () {
                builder.element('value', nest: () {
                  builder.text('${withJid.localPart}@${withJid.domainPart}');
                });
              });
            }
            if (start != null) {
              builder.element('field', attributes: {
                'var': 'start',
              }, nest: () {
                builder.element('value', nest: () {
                  builder.text(start.toIso8601String());
                });
              });
            }
            if (end != null) {
              builder.element('field', attributes: {
                'var': 'end',
              }, nest: () {
                builder.element('value', nest: () {
                  builder.text(end.toIso8601String());
                });
              });
            }
          },
        );
        // Result Set Maangement (RSM) [xep-0059]
        // TODO: Make RSM a data class with its own helper function
        builder.element('set', attributes: {
          'xmlns': 'http://jabber.org/protocol/rsm',
        }, nest: () {
          if (max != null) {
            builder.element('max', nest: () {
              builder.text(max.toString());
            });
          }
          if (before != null) {
            builder.element('before', nest: () {
              builder.text(before);
            });
          }
          if (after != null) {
            builder.element('after', nest: () {
              builder.text(after);
            });
          }
        });
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument buildBasicChatMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
    required XempiJid to,
    required String body,
  }) {
    final builder = XmlBuilder();
    builder.element('message', attributes: {
      'from': accountSettings.jid.toString(),
      'to': to.toString(),
      'type': 'chat',
    }, nest: () {
      builder.element('body', nest: () {
        builder.text(body);
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument buildBasicChatMessageWithOriginId({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
    required XempiJid to,
    required String body,
  }) {
    Uuid uuid = const Uuid();
    String originId = uuid.v4();

    final builder = XmlBuilder();
    builder.element('message', attributes: {
      'from': accountSettings.jid.toString(),
      'to': to.toString(),
      'type': 'chat',
      'id': originId,
    }, nest: () {
      builder.element('body', nest: () {
        builder.text(body);
      });
      builder.element(
        'origin-id',
        attributes: {
          'xmlns': 'urn:xmpp:sid:0',
          'id': originId,
        },
      );
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument buildMessageRetractionMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
    required XempiJid to,
    required String id,
    bool store = false,
  }) {
    Uuid uuid = const Uuid();
    String originId = uuid.v4();

    final builder = XmlBuilder();
    builder.element('message', attributes: {
      'from': accountSettings.jid.toString(), // Optional
      'to': to.toString(), // Required
      'type': 'chat',
      'id': originId,
    }, nest: () {
      builder.element(
        'retract',
        attributes: {
          'xmlns': 'urn:xmpp:message-retract:1',
          'id': id,
        },
      );
      builder.element('fallback', attributes: {
        'xmlns': 'urn:xmpp:fallback:0',
        'for': 'urn:xmpp:message-retract:1'
      });
      builder.element('body', nest: () {
        builder.text(
          'This person attempted to retract a previous '
          'message, but it\'s unsupported by your client.',
        );
      });
      if (store == true) {
        builder.element('store', attributes: {'xmlns': 'urn:xmpp:hints'});
      }
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  static XmlDocument buildIqGetRoster({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
  }) {
    final builder = XmlBuilder();
    Uuid uuid = const Uuid();
    builder.element('iq', attributes: {
      'id': uuid.v4(),
      'type': 'get',
    }, nest: () {
      builder.element('query', attributes: {
        'xmlns': 'jabber:iq:roster',
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }
}
