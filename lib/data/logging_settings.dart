/// Defines configurations to log specific types of XML messages.
class XempiLoggingSettings {
  // TODO: Consider nonzas and other connection messages
  final bool outboundMessageStanzas;
  final bool inboundMessageStanzas;

  final bool outboundIqStanzas;
  final bool inboundIqStanzas;

  final bool outboundPresenceStanzas;
  final bool inboundPresenceStanzas;

  XempiLoggingSettings({
    this.outboundMessageStanzas = false,
    this.inboundMessageStanzas = false,
    this.outboundIqStanzas = false,
    this.inboundIqStanzas = false,
    this.outboundPresenceStanzas = false,
    this.inboundPresenceStanzas = false,
  });

  const XempiLoggingSettings.all()
      : outboundMessageStanzas = true,
        inboundMessageStanzas = true,
        outboundIqStanzas = true,
        inboundIqStanzas = true,
        outboundPresenceStanzas = true,
        inboundPresenceStanzas = true;
}
