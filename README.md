# XEMPI

This library is an implementation of the XMPP protocol to be used in Flutter Multiplatform apps.

> __Note__: THIS LIBRARY IS BEING DEVELOPED FOR A PERSONAL USE CASE AND IT'S NOT YET READY FOR THE PUBLIC. USE WITH CAUTION. WHEN THIS CODEBASE BECOMES MORE STABLE IT WILL BE DEVELOPED AS AN OPEN SOURCE PROJECT

## XMPP

XMPP is a messaginc protocol based on XML. Its fundamental elements are defined in the **Extensible Messaging and Presence Protocol (XMPP): Core** RFC document (RFC6120).

According to that document, XMPP is defined as follows: 

The Extensible Messaging and Presence Protocol (XMPP) is an
  application profile of the Extensible Markup Language (XML) that
  enables the near-real-time exchange of structured yet extensible data
  between any two or more network entities.  This document defines
  XMPP's core protocol methods: setup and teardown of XML streams,
  channel encryption, authentication, error handling, and communication
  primitives for messaging, network availability ("presence"), and
  request-response interactions.

## XMPP Connection Process

1.  Determine the IP address and port at which to connect, typically
    based on resolution of a fully qualified domain name

2.  Open a Transmission Control Protocol [TCP] connection

3.  Open an XML stream over TCP

4.  Preferably negotiate Transport Layer Security [TLS] for channel
    encryption

5.  Authenticate using a Simple Authentication and Security Layer
    [SASL] mechanism

6.  Bind a resource to the stream

7.  Exchange an unbounded number of XML stanzas with other entities
    on the network

8.  Close the XML stream

9.  Close the TCP connection

## JID

JIDs are the basic form of identity in XMPP implementations. It usually describes a particular account that belongs to a server but can be used in different ways. The details of the JID address format can be found on RFC6122.

* **domainpart**: In this case, **domainpart** references to the server being used. It should be an IP Address or a FQDN that can be resolved to an IP Address to connect to using the TCP protocol.
* **localpart@domainpart**: This case describes a specific account (with **localpart**) connected to a specific XMPP server (referenced by **domainpart**).  Local Parts usually refer to accounts or device IDs depending the use of the implementation.
* **localpart@domainpart/resourcepart**: This case is considered a "full JID" and describes a particular resource from a server. Typically a resourcepart uniquely
identifies a specific connection (e.g., a device or location) or
object (e.g., an occupant in a multi-user chat room) belonging to the
entity associated with an XMPP localpart at a domain (i.e.,
<localpart@domainpart/resourcepart>).

The term "bare JID" refers to an XMPP address of the form
<localpart@domainpart> (for an account at a server) or of the form
<domainpart> (for a server).

The term "full JID" refers to an XMPP address of the form
<localpart@domainpart/resourcepart> (for a particular authorized
client or device associated with an account) or of the form
<domainpart/resourcepart> (for a particular resource or script
associated with a server).

When using XEMPI, you can create JIDs using the XempiJid class. The only parameter required is the Domain Part as per the specification.

```Dart
XempiJid domainPartJid = XempiJid(domainPart: 'myserver.com');
print(domainPartJid) // prints "myserver.com"

XempiJid bareJid = XempiJid(localPart: 'myusername', domainPart: 'myserver.com');
print(bareJid) // prints "myusername@myserver.com"

XempiJid fullJid = XempiJid(
  localPart: 'myusername',
  domainPart: 'myserver.com',
  resourcePart: 'connectionID'
);
print(fullJid) // prints "myusername@myserver.com/connectionID"
```

## Stanza

A Stanza is a message sent over the XMPP "XML Stream". There are three types of Stanzas:

* Message
* Presence
* IQ (short for Info/Query)

<presence/>

## XEPs

XMPP defines specific parts of the implementation as Extensions to the protocol also called XEPs.

* [XMPP-IM] Saint-Andre, P., "Extensible Messaging and Presence
  Protocol (XMPP): Instant Messaging and Presence",
  RFC 6121
* [XEP-0001] Saint-Andre, P., "XMPP Extension Protocols", XSF
  XEP 0001, March 2010.