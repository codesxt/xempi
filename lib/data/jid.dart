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
}
