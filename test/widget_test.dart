import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_buddy/core/widgets/buddy_avatar.dart';
import 'package:learn_buddy/core/widgets/meter_paham_bar.dart';
import 'package:learn_buddy/l10n/app_localizations.dart';

void main() {
  testWidgets('MeterPahamBar and BuddyAvatar render localized Indonesian mood',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('id'),
        supportedLocales: [Locale('id'), Locale('en')],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Column(
            children: [
              BuddyAvatar(meterPercent: 85),
              MeterPahamBar(meterPercent: 85),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('85%'), findsOneWidget);
    expect(find.text('Paham'), findsOneWidget);
  });
}
