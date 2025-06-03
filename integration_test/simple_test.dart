import 'package:flutter_test/flutter_test.dart';
import 'package:yumcha/main.dart';
import 'package:yumcha/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());
  testWidgets('Can call rust function', (WidgetTester tester) async {
    await tester.pumpWidget(const YumchaApp());
    expect(find.textContaining('欢迎使用 YumCha AI助手'), findsOneWidget);
  });
}
