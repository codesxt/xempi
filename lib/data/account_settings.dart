import 'package:xempi/data/jid.dart';

class XempiAccountSettings {
  XempiJid jid;
  String password;

  XempiAccountSettings({
    required this.jid,
    this.password = '',
  });
}
