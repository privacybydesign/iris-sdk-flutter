import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iris_sdk_flutter_example/main.dart';

/// Widget-level smoke test over a mocked channel. The real platform coverage
/// is the iOS and Android builds in CI; this only guards the example's own
/// wiring so a broken example fails fast, before a 10-minute native build.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('iris_sdk_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      return switch (call.method) {
        'version' => '1.2.3',
        'verify' => {'outcome': 'cancelled'},
        _ => null,
      };
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  testWidgets('shows the SDK version and the outcome of a verification', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('SDK version: 1.2.3'), findsOneWidget);

    await tester.tap(find.text('Run face verification'));
    await tester.pumpAndSettle();

    expect(find.text('Outcome: cancelled'), findsOneWidget);
  });
}
