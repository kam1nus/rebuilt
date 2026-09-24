import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroyostatok_flutter/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-public-key',
    );
  });

  testWidgets('shows authentication before the marketplace', (tester) async {
    await tester.pumpWidget(const StroyOstatokApp());

    expect(find.text('Welcome back to ReBuild'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('shows an empty state instead of sample sale listings', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BuyScreen(onSell: () {}, refreshToken: 0)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in to view materials'), findsOneWidget);
    expect(find.text('Grey porcelain tiles'), findsNothing);
    expect(find.text('Tikkurila paint'), findsNothing);
    expect(find.text('Kitchen faucet'), findsNothing);
  });
}
