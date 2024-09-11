part of 'message_helper.dart';

/// Helper class to implement [XEP-0085: Chat State Notifications].
///
/// This class defines utility methods to build messages with the
/// following chat state elements:
/// * active
/// * inactive
/// * gone
/// * composing
/// * paused
///
/// More info: [xep-0085](https://xmpp.org/extensions/xep-0085.html)
class XempiChatStatesHelper {
  const XempiChatStatesHelper();

  /// Builds a <message/> element that contains an <active/> element as per
  /// [XEP-0085].
  ///
  /// Example of a resulting message:
  /// ```xml
  /// <message from="username@host/resource" to="otherusername@otherhost" type="chat">
  ///   <active xmlns="http://jabber.org/protocol/chatstates"/>
  /// </message>
  /// ```
  XmlDocument buildActiveMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
    required XempiJid to,
  }) {
    final builder = XmlBuilder();
    builder.element('message', attributes: {
      'from': accountSettings.jid.toString(),
      'to': to.toString(),
      'type': 'chat',
    }, nest: () {
      builder.element('active', attributes: {
        'xmlns': 'http://jabber.org/protocol/chatstates',
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  /// Builds a <message/> element that contains an <inactive/> element as per
  /// [XEP-0085].
  ///
  /// Example of a resulting message:
  /// ```xml
  /// <message from="username@host/resource" to="otherusername@otherhost" type="chat">
  ///   <inactive xmlns="http://jabber.org/protocol/chatstates"/>
  /// </message>
  /// ```
  XmlDocument buildInactiveMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
    required XempiJid to,
  }) {
    final builder = XmlBuilder();
    builder.element('message', attributes: {
      'from': accountSettings.jid.toString(),
      'to': to.toString(),
      'type': 'chat',
    }, nest: () {
      builder.element('inactive', attributes: {
        'xmlns': 'http://jabber.org/protocol/chatstates',
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  /// Builds a <message/> element that contains an <gone/> element as per
  /// [XEP-0085].
  ///
  /// Example of a resulting message:
  /// ```xml
  /// <message from="username@host/resource" to="otherusername@otherhost" type="chat">
  ///   <gone xmlns="http://jabber.org/protocol/chatstates"/>
  /// </message>
  /// ```
  XmlDocument buildGoneMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
    required XempiJid to,
  }) {
    final builder = XmlBuilder();
    builder.element('message', attributes: {
      'from': accountSettings.jid.toString(),
      'to': to.toString(),
      'type': 'chat',
    }, nest: () {
      builder.element('gone', attributes: {
        'xmlns': 'http://jabber.org/protocol/chatstates',
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  /// Builds a <message/> element that contains an <composing/> element as per
  /// [XEP-0085].
  ///
  /// Example of a resulting message:
  /// ```xml
  /// <message from="username@host/resource" to="otherusername@otherhost" type="chat">
  ///   <composing xmlns="http://jabber.org/protocol/chatstates"/>
  /// </message>
  /// ```
  XmlDocument buildComposingMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
    required XempiJid to,
  }) {
    final builder = XmlBuilder();
    builder.element('message', attributes: {
      'from': accountSettings.jid.toString(),
      'to': to.toString(),
      'type': 'chat',
    }, nest: () {
      builder.element('composing', attributes: {
        'xmlns': 'http://jabber.org/protocol/chatstates',
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }

  /// Builds a <message/> element that contains an <paused/> element as per
  /// [XEP-0085].
  ///
  /// Example of a resulting message:
  /// ```xml
  /// <message from="username@host/resource" to="otherusername@otherhost" type="chat">
  ///   <paused xmlns="http://jabber.org/protocol/chatstates"/>
  /// </message>
  /// ```
  XmlDocument buildPausedMessage({
    required XempiConnectionSettings connectionSettings,
    required XempiAccountSettings accountSettings,
    required XempiJid to,
  }) {
    final builder = XmlBuilder();
    builder.element('message', attributes: {
      'from': accountSettings.jid.toString(),
      'to': to.toString(),
      'type': 'chat',
    }, nest: () {
      builder.element('paused', attributes: {
        'xmlns': 'http://jabber.org/protocol/chatstates',
      });
    });
    XmlDocument document = builder.buildDocument();
    return document;
  }
}
