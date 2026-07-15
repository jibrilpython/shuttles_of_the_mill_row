import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttles_of_the_mill_row/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App boots to initial or home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(child: MyApp(preferences: preferences)),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('SHUTTLES'), findsWidgets);
  });
}
