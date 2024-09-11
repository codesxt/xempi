import 'dart:convert';

/// Described by https://datatracker.ietf.org/doc/html/rfc7622.
///
/// "The domainpart is the primary identifier and is the only REQUIRED
///  element of a JID (a mere domainpart is a valid JID)."
class XempiJid {
  String localPart;
  String domainPart;
  String resourcePart;

  XempiJid({
    this.localPart = '',
    required this.domainPart,
    this.resourcePart = '',
  });

  XempiJid copyWith({
    String? localPart,
    String? domainPart,
    String? resourcePart,
  }) {
    return XempiJid(
      localPart: localPart ?? this.localPart,
      domainPart: domainPart ?? this.domainPart,
      resourcePart: resourcePart ?? this.resourcePart,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'localPart': localPart,
      'domainPart': domainPart,
      'resourcePart': resourcePart,
    };
  }

  factory XempiJid.fromMap(Map<String, dynamic> map) {
    return XempiJid(
      localPart: map['localPart'] ?? '',
      domainPart: map['domainPart'] ?? '',
      resourcePart: map['resourcePart'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory XempiJid.fromJson(String source) =>
      XempiJid.fromMap(json.decode(source));

  @override
  String toString() {
    String representation = '';
    if (localPart.isNotEmpty) {
      representation += '$localPart@';
    }
    representation += domainPart;
    if (resourcePart.isNotEmpty) {
      representation += '/$resourcePart';
    }
    return representation;
  }

  /// Prints a "Bare JID" [String] representation (only local and domain parts).
  String toBareJidString() {
    String representation = '';
    if (localPart.isNotEmpty) {
      representation += '$localPart@';
    }
    representation += domainPart;
    return representation;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is XempiJid &&
        other.localPart == localPart &&
        other.domainPart == domainPart &&
        other.resourcePart == resourcePart;
  }

  @override
  int get hashCode =>
      localPart.hashCode ^ domainPart.hashCode ^ resourcePart.hashCode;

  /// Parses a string into a `XempiJid` object.
  /// Throws an error if the string is not a valid JID (missing domain part).
  factory XempiJid.parse(String jidString) {
    return XempiJidParser.parse(jidString);
  }
}

class XempiJidParser {
  static XempiJid parse(String jidString) {
    // Handle cases without local part (@)
    if (!jidString.contains('@')) {
      final parts = jidString.split('/');
      String resourcePart = parts.length > 1 ? parts[1] : '';
      _validateResourcePart(resourcePart);
      return XempiJid(
        localPart: '',
        domainPart: parts[0],
        resourcePart: resourcePart,
      );
    } else {
      // Handle cases with local part (@)
      final parts = jidString.split('@');
      if (parts.length < 2) {
        throw ArgumentError('Invalid JID: Missing domain part.');
      }
      final domainPart = parts[1];
      final localPart = parts[0];
      final resourcePart = domainPart.split('/').length > 1
          ? domainPart.split('/').sublist(1).join('/')
          : '';
      _validateResourcePart(resourcePart);
      return XempiJid(
        localPart: localPart,
        domainPart: domainPart.split('/')[0],
        resourcePart: resourcePart,
      );
    }
  }

  static bool _validateResourcePart(String resourcePart) {
    // Check if resource part is valid
    if (resourcePart.isNotEmpty) {
      // Check if the resource part is valid based on XMPP rules
      if (resourcePart.length > 256 ||
          resourcePart.contains(RegExp(r'[\x00-\x1F\xFFFE\xFFFF]')) ||
          resourcePart.contains(RegExp(r'[^\x20-\uD7FF\uE000-\uFFFF]')) ||
          resourcePart.isEmpty) {
        throw ArgumentError(
            'Invalid JID: Resource part is invalid according to XMPP rules.');
      }
    }
    return true;
  }
}
