import 'package:flutter_test/flutter_test.dart';
import 'package:msh_map/app.dart';

void main() {
  testWidgets('MSH Map smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MshMapApp());

    // Basic smoke test - app should build without crashing
    expect(find.byType(MshMapApp), findsOneWidget);
  });
}
