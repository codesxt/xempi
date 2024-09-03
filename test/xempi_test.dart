import 'package:flutter_test/flutter_test.dart';
import 'package:xempi/xempi.dart';
import 'package:xempi/xempi_platform_interface.dart';
import 'package:xempi/xempi_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockXempiPlatform
    with MockPlatformInterfaceMixin
    implements XempiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final XempiPlatform initialPlatform = XempiPlatform.instance;

  test('$MethodChannelXempi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelXempi>());
  });

  test('getPlatformVersion', () async {
    Xempi xempiPlugin = Xempi();
    MockXempiPlatform fakePlatform = MockXempiPlatform();
    XempiPlatform.instance = fakePlatform;

    expect(await xempiPlugin.getPlatformVersion(), '42');
  });
}
