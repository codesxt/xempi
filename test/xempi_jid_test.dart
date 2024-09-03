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
}
