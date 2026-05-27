import 'package:flutter_test/flutter_test.dart';
import 'package:bt_remote/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const BTRemoteApp());
    expect(find.text('BT Remote'), findsAny);
  });
}
