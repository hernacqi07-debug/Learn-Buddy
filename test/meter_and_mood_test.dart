import 'package:flutter_test/flutter_test.dart';
import 'package:learn_buddy/core/models/models.dart';

void main() {
  group('BuddyMood.fromMeter mapping', () {
    test('maps 0-19 to confused', () {
      expect(BuddyMood.fromMeter(0), BuddyMood.confused);
      expect(BuddyMood.fromMeter(19), BuddyMood.confused);
    });

    test('maps 20-39 to thinking', () {
      expect(BuddyMood.fromMeter(20), BuddyMood.thinking);
      expect(BuddyMood.fromMeter(39), BuddyMood.thinking);
    });

    test('maps 40-59 to doubtful', () {
      expect(BuddyMood.fromMeter(40), BuddyMood.doubtful);
      expect(BuddyMood.fromMeter(59), BuddyMood.doubtful);
    });

    test('maps 60-79 to starting', () {
      expect(BuddyMood.fromMeter(60), BuddyMood.starting);
      expect(BuddyMood.fromMeter(79), BuddyMood.starting);
    });

    test('maps 80-99 to understands', () {
      expect(BuddyMood.fromMeter(80), BuddyMood.understands);
      expect(BuddyMood.fromMeter(99), BuddyMood.understands);
    });

    test('maps 100 and clamped bounds to happy/confused', () {
      expect(BuddyMood.fromMeter(100), BuddyMood.happy);
      expect(BuddyMood.fromMeter(120), BuddyMood.happy);
      expect(BuddyMood.fromMeter(-10), BuddyMood.confused);
    });
  });

  group('Model parsing', () {
    test('SessionStatus parses all 4 statuses cleanly', () {
      expect(SessionStatus.fromString('active'), SessionStatus.active);
      expect(SessionStatus.fromString('completed'), SessionStatus.completed);
      expect(SessionStatus.fromString('incomplete'), SessionStatus.incomplete);
      expect(SessionStatus.fromString('abandoned'), SessionStatus.abandoned);
    });

    test('TeachTurnResult parses edge function payload', () {
      final res = TeachTurnResult.fromMap({
        'buddy_reply': 'Oh gitu ya?',
        'next_buddy_intro': 'Kalau soal tengah stack gimana?',
        'active_misconception_id': 'm2',
        'meter_percent': 33,
        'inputs_used': 4,
        'inputs_max': 20,
        'session_status': 'active',
      });

      expect(res.buddyReply, 'Oh gitu ya?');
      expect(res.nextBuddyIntro, 'Kalau soal tengah stack gimana?');
      expect(res.meterPercent, 33);
      expect(res.inputsUsed, 4);
      expect(res.inputsMax, 20);
      expect(res.sessionStatus, SessionStatus.active);
    });

    test('TopicSummary localization falls back to ID when EN empty', () {
      const topic = TopicSummary(
        id: '1',
        titleId: 'Stack (Tumpukan)',
        titleEn: '',
        descriptionId: 'Deskripsi ID',
        descriptionEn: '',
        sortOrder: 1,
        enReady: false,
        bestMeterPercent: 89,
        hasCompleted80: true,
      );
      expect(topic.localizedTitle('en'), 'Stack (Tumpukan)');
      expect(topic.localizedTitle('id'), 'Stack (Tumpukan)');
    });
  });
}
