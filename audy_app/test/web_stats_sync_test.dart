import 'dart:convert';

import 'package:audy_app/src/services/web_stats_sync.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  Map<String, dynamic> row(int points, int games) => {
    'student_id': 'student-a',
    'learning_points': points,
    'games_played': games,
    'day_streak': 9,
    'last_played_at': '2026-10-27T00:00:00Z',
  };
  Future<void> save(SupabaseClient client) => WebStatsSync(
    client,
    clock: () => DateTime.utc(2026, 10, 27, 12),
  ).save('student-a', learningPoints: 5, gamesPlayed: 1, dayStreak: 1);

  test('web streak follows the existing consecutive/missed day rule', () {
    expect(webDayStreak(row(5, 1), now: DateTime.utc(2026, 10, 28, 1)), 10);
    expect(webDayStreak(row(5, 1), now: DateTime.utc(2026, 10, 29, 1)), 1);
  });

  test('fresh browser cannot reduce mobile points, games, or streak', () async {
    final client = SupabaseClient(
      'https://example.supabase.co',
      'key',
      httpClient: MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode(row(120, 20)),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }
        final data = jsonDecode(request.body);
        expect(data['learning_points'], 120);
        expect(data['games_played'], 20);
        expect(data['day_streak'], 9);
        expect(request.url.queryParameters['learning_points'], 'eq.120');
        expect(
          request.url.queryParameters['last_played_at'],
          'eq.2026-10-27T00:00:00Z',
        );
        return http.Response(
          '[{"student_id":"student-a"}]',
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    await save(client);
    await client.dispose();
  });

  test('concurrent mobile write retries against new cloud totals', () async {
    var reads = 0;
    var writes = 0;
    final client = SupabaseClient(
      'https://example.supabase.co',
      'key',
      httpClient: MockClient((request) async {
        if (request.method == 'GET') {
          reads++;
          return http.Response(
            jsonEncode(row(reads == 1 ? 120 : 150, 20)),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }
        writes++;
        if (writes == 1) {
          return http.Response(
            '[]',
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }
        expect(jsonDecode(request.body)['learning_points'], 150);
        expect(request.url.queryParameters['learning_points'], 'eq.150');
        return http.Response(
          '[{"student_id":"student-a"}]',
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    await save(client);
    expect(reads, 2);
    expect(writes, 2);
    await client.dispose();
  });

  test(
    'insert race reloads existing stats instead of upserting stale totals',
    () async {
      var reads = 0;
      var inserts = 0;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'key',
        httpClient: MockClient((request) async {
          if (request.method == 'GET') {
            reads++;
            return http.Response(
              reads == 1 ? 'null' : jsonEncode(row(60, 10)),
              200,
              request: request,
              headers: {'content-type': 'application/json'},
            );
          }
          if (request.method == 'POST') {
            inserts++;
            return http.Response(
              '{"code":"23505","message":"duplicate"}',
              409,
              request: request,
              headers: {'content-type': 'application/json'},
            );
          }
          expect(jsonDecode(request.body)['learning_points'], 60);
          return http.Response(
            '[{"student_id":"student-a"}]',
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      await save(client);
      expect(inserts, 1);
      expect(reads, 2);
      await client.dispose();
    },
  );

  test('failed cloud read never attempts an absolute overwrite', () async {
    final client = SupabaseClient(
      'https://example.supabase.co',
      'key',
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        return http.Response(
          '{"message":"offline"}',
          400,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    await expectLater(save(client), throwsA(isA<PostgrestException>()));
    await client.dispose();
  });
}
