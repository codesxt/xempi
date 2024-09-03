import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xempi/xempi.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<XmlDocument> inboundMessages = [];
  List<XmlDocument> outboundMessages = [];

  String jidLocalPart = dotenv.env['JID_LOCAL_PART'] ?? '';
  String jidDomainPart = dotenv.env['JID_DOMAIN_PART'] ?? '';
  String jidResourcePart = dotenv.env['JID_RESOURCE_PART'] ?? '';
  String password = dotenv.env['PASSWORD'] ?? '';
  String host = dotenv.env['HOST'] ?? '';
  int port = int.parse(dotenv.maybeGet('PORT', fallback: '0')!);
  int portWeb = int.parse(dotenv.maybeGet('PORT_WEB', fallback: '0')!);

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Xempi Example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Inbound',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Outbound',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    flex: 1,
                    child: ListView.separated(
                      reverse: true,
                      itemCount: inboundMessages.length,
                      itemBuilder: (context, index) {
                        XmlDocument document = inboundMessages[index];
                        XmlElement root = document.rootElement;
                        String type = root.getAttribute('type').toString();

                        return ExpansionTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(
                                label: Text(root.name.local),
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    type,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                document.toXmlString(),
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(height: 1);
                      },
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: ListView.separated(
                      reverse: true,
                      itemCount: outboundMessages.length,
                      itemBuilder: (context, index) {
                        XmlDocument document = outboundMessages[index];
                        XmlElement root = document.rootElement;
                        String type = root.getAttribute('type').toString();

                        return ExpansionTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(
                                label: Text(root.name.local),
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    type,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                document.toXmlString(),
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(height: 1);
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Initialize plugin code.
  initialize() {
    XempiAccountSettings accountSettings = XempiAccountSettings(
      jid: XempiJid(
        localPart: jidLocalPart,
        domainPart: jidDomainPart,
        resourcePart: jidResourcePart,
      ),
      password: password,
    );

    XempiConnectionSettings connectionSettings = XempiConnectionSettings(
      host: host,
      port: kIsWeb ? portWeb : port,
    );

    XempiConnectionManager connectionManager = XempiConnectionManager(
      connectionSettings: connectionSettings,
      accountSettings: accountSettings,
      onConnectionAvailable: (connection) async {
        // Run code here after connection is stablished
      },
    );

    connectionManager.inboundMessages.stream.listen(_onInboundMessage);
    connectionManager.outboundMessages.stream.listen(_onOutoundMessage);

    connectionManager.connect();
  }

  _onInboundMessage(XmlDocument document) async {
    inboundMessages.add(document);
    setState(() {});
  }

  _onOutoundMessage(XmlDocument document) async {
    outboundMessages.add(document);
    setState(() {});
  }
}
