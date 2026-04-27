import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:phos_mobile/main.dart';

void main() {
  testWidgets('renders the Phos home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PhotoBoothApp());
    await tester.pumpAndSettle();

    expect(find.text('Phos'), findsOneWidget);
    expect(find.text('CAPTURE THE MOMENT'), findsOneWidget);
    expect(find.text('Take a Shot'), findsOneWidget);
  });
}
