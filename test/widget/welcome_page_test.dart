import 'package:flutter_test/flutter_test.dart';

import 'package:ecosea/pages/welcome_page.dart';
import 'package:ecosea/pages/login_page.dart';

import '../helpers/test_utils.dart';

void main() {
  group('Widget Test - WelcomePage', () {
    testWidgets('Tombol "Get Started" menavigasi ke LoginPage', (tester) async {
      setTestSurfaceSize(tester);
      addTearDown(() => clearTestSurfaceSize(tester));

      await tester.pumpWidget(buildTestableWidget(const WelcomePage()));

      expect(find.text('Selamat Datang!'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });
}
