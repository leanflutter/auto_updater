import 'package:auto_updater_platform_interface/auto_updater_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelAutoUpdater', () {
    test('installUpdateNow invokes native immediate install method', () async {
      final updater = MethodChannelAutoUpdater();
      final calls = <MethodCall>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(updater.methodChannel, (call) async {
            calls.add(call);
            return true;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(updater.methodChannel, null);
      });

      await updater.installUpdateNow();

      expect(calls, hasLength(1));
      expect(calls.single.method, 'installUpdateImmediately');
      expect(calls.single.arguments, isNull);
    });
  });
}
