import 'package:flutter_test/flutter_test.dart';
import 'package:xempi/data/jid.dart';

void main() {
  test('Jid format for Domain part only', () {
    XempiJid jid = XempiJid(
      domainPart: 'domain.fqdnexample.tld',
    );

    expect(jid.toString(), isInstanceOf<String>());
    expect(jid.toString(), 'domain.fqdnexample.tld');
  });

  test('Jid format for Local and Domain parts', () {
    XempiJid jid = XempiJid(
      localPart: 'exampleuser',
      domainPart: 'domain.fqdnexample.tld',
    );

    expect(jid.toString(), isInstanceOf<String>());
    expect(jid.toString(), 'exampleuser@domain.fqdnexample.tld');
  });

  test('Jid format for Local, Domain and Resource parts', () {
    XempiJid jid = XempiJid(
        localPart: 'exampleuser',
        domainPart: 'domain.fqdnexample.tld',
        resourcePart: 'serverresource');

    expect(jid.toString(), isInstanceOf<String>());
    expect(jid.toString(), 'exampleuser@domain.fqdnexample.tld/serverresource');
  });

  group('Parse tests', () {
    test('Parse domain only', () {
      final jid = XempiJid.parse('domain.fqdnexample.tld');
      expect(jid.localPart, '');
      expect(jid.domainPart, 'domain.fqdnexample.tld');
      expect(jid.resourcePart, '');
    });

    test('Parse local and domain', () {
      final jid = XempiJid.parse('exampleuser@domain.fqdnexample.tld');
      expect(jid.localPart, 'exampleuser');
      expect(jid.domainPart, 'domain.fqdnexample.tld');
      expect(jid.resourcePart, '');
    });

    test('Parse local, domain, and resource', () {
      final jid =
          XempiJid.parse('exampleuser@domain.fqdnexample.tld/serverresource');
      expect(jid.localPart, 'exampleuser');
      expect(jid.domainPart, 'domain.fqdnexample.tld');
      expect(jid.resourcePart, 'serverresource');
    });

    test('Parse with special characters', () {
      final jid =
          XempiJid.parse('example_user@domain.fqdnexample.tld/resource_1');
      expect(jid.localPart, 'example_user');
      expect(jid.domainPart, 'domain.fqdnexample.tld');
      expect(jid.resourcePart, 'resource_1');
    });

    test('Parse with multiple slashes', () {
      final jid = XempiJid.parse(
          'exampleuser@domain.fqdnexample.tld/resource/subresource');
      expect(jid.localPart, 'exampleuser');
      expect(jid.domainPart, 'domain.fqdnexample.tld');
      expect(jid.resourcePart, 'resource/subresource');
    });

    test('Parse domain only with slash', () {
      final jid = XempiJid.parse('domain.fqdnexample.tld/resource');
      expect(jid.localPart, '');
      expect(jid.domainPart, 'domain.fqdnexample.tld');
      expect(jid.resourcePart, 'resource');
    });

    test('Parse only domain (no @)', () {
      final jid = XempiJid.parse('domain.fqdnexample.tld');
      expect(jid.localPart, '');
      expect(jid.domainPart, 'domain.fqdnexample.tld');
      expect(jid.resourcePart, '');
    });

    test('Invalid JID: Resource with invalid character', () {
      expect(
          () => XempiJid.parse(
              'exampleuser@domain.fqdnexample.tld/invalid\u001Fcharacter'),
          throwsArgumentError);
    });
  });
}
