import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecosea/pages/login_page.dart';
import 'package:ecosea/pages/register_page.dart';

import '../helpers/test_utils.dart';

void main() {
  group('Widget Test - RegisterPage', () {
    testWidgets('Menampilkan error jika semua field kosong', (tester) async {
      setTestSurfaceSize(tester);
      addTearDown(() => clearTestSurfaceSize(tester));

      await tester.pumpWidget(buildTestableWidget(const RegisterPage()));

      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Validasi nama minimal 3 karakter', (tester) async {
      setTestSurfaceSize(tester);
      addTearDown(() => clearTestSurfaceSize(tester));

      await tester.pumpWidget(buildTestableWidget(const RegisterPage()));

      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final passField = find.byType(TextFormField).at(2);

      await tester.enterText(nameField, 'ab');
      await tester.enterText(emailField, 'user@email.com');
      await tester.enterText(passField, '123456');

      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Nama minimal 3 karakter'), findsOneWidget);
    });

    testWidgets('Tombol "Already have..." kembali ke LoginPage (pop)', (tester) async {
      setTestSurfaceSize(tester);
      addTearDown(() => clearTestSurfaceSize(tester));

      // Buat alur realistis: LoginPage -> push RegisterPage -> pop kembali.
      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterPage), findsOneWidget);

      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });
}
