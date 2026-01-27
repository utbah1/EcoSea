import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecosea/pages/login_page.dart';
import 'package:ecosea/pages/register_page.dart';

import '../helpers/test_utils.dart';

void main() {
  group('Widget Test - LoginPage', () {
    testWidgets('Menampilkan error jika email/password kosong', (tester) async {
      setTestSurfaceSize(tester);
      addTearDown(() => clearTestSurfaceSize(tester));

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Validasi email: format tidak valid', (tester) async {
      setTestSurfaceSize(tester);
      addTearDown(() => clearTestSurfaceSize(tester));

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      final emailField = find.byType(TextFormField).at(0);
      final passField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'abc');
      await tester.enterText(passField, '123456');

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Format email tidak valid'), findsOneWidget);
      expect(find.text('Password minimal 6 karakter'), findsNothing);
    });

    testWidgets('Validasi password: minimal 6 karakter', (tester) async {
      setTestSurfaceSize(tester);
      addTearDown(() => clearTestSurfaceSize(tester));

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      final emailField = find.byType(TextFormField).at(0);
      final passField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'user@email.com');
      await tester.enterText(passField, '123');

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('Password field menggunakan obscureText', (tester) async {
      setTestSurfaceSize(tester);
      addTearDown(() => clearTestSurfaceSize(tester));

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      // TextFormField membungkus TextField; properti obscureText yang benar ada di TextField.
      final innerTextField = find.descendant(
        of: find.byType(TextFormField).at(1),
        matching: find.byType(TextField),
      );

      expect(innerTextField, findsOneWidget);

      final tf = tester.widget<TextField>(innerTextField);
      expect(tf.obscureText, isTrue);
    });

    testWidgets('Teks register menavigasi ke RegisterPage', (tester) async {
      setTestSurfaceSize(tester);
      addTearDown(() => clearTestSurfaceSize(tester));

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}
