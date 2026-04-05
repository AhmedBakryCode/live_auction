import 'package:flutter_test/flutter_test.dart';

import 'package:live_auction/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LiveAuctionAdminApp(initialRoute: '/'));

    // Wait for the app to render
    await tester.pumpAndSettle();
  });
}
