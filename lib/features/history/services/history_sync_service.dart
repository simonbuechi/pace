import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pace_amigo/core/config/firebase_config.dart';
import 'package:pace_amigo/features/history/models/focus_run_log.dart';

class HistorySyncService {
  final http.Client _client;

  HistorySyncService({http.Client? client}) : _client = client ?? http.Client();

  /// Syncs a single focus run log with the Firebase Firestore backend.
  Future<bool> syncLog(FocusRunLog log) async {
    if (!FirebaseConfig.isConfigured) {
      debugPrint('Firebase not configured, skipping cloud sync.');
      return false;
    }

    try {
      final projectId = FirebaseConfig.projectId;
      final apiKey = FirebaseConfig.apiKey;

      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/focus_history/${log.id}?key=$apiKey',
      );

      final body = jsonEncode({
        'fields': {
          'id': {'stringValue': log.id},
          'presetId': {'stringValue': log.presetId},
          'presetName': {'stringValue': log.presetName},
          'focusDurationSeconds': {
            'integerValue': log.focusDurationSeconds.toString(),
          },
          'totalDurationSeconds': {
            'integerValue': log.totalDurationSeconds.toString(),
          },
          'iterations': {
            'integerValue': log.iterations.toString(),
          },
          'completedAt': {
            'timestampValue': log.completedAt.toUtc().toIso8601String(),
          },
        },
      });

      final response = await _client
          .patch(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Successfully synced run ${log.id} to Firebase!');
        return true;
      } else {
        debugPrint(
          'Firebase sync response ${response.statusCode}: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Firebase sync error: $e');
      return false;
    }
  }

  /// Retries syncing all unsynced logs
  Future<List<String>> syncBatch(List<FocusRunLog> logs) async {
    final syncedIds = <String>[];
    for (final log in logs) {
      final ok = await syncLog(log);
      if (ok) syncedIds.add(log.id);
    }
    return syncedIds;
  }
}
