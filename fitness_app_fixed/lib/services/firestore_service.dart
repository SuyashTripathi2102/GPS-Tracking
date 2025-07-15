import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _failedGpsQueue = [];
  final List<Map<String, dynamic>> _failedActivityQueue = [];

  FirestoreService() {
    _db.settings = const Settings(persistenceEnabled: true);
  }

  Future<void> uploadGpsData(Map<String, dynamic> gpsData) async {
    try {
      await _db.collection('gps_data').add({
        ...gpsData,
        'syncedAt': DateTime.now().toIso8601String(),
      });
      print('✅ GPS data synced to cloud');
    } catch (e) {
      print('❌ Failed to sync GPS data: $e');
      _failedGpsQueue.add(gpsData);
    }
  }

  Future<void> uploadActivityData(Map<String, dynamic> activityData) async {
    try {
      await _db.collection('activity_data').add({
        ...activityData,
        'syncedAt': DateTime.now().toIso8601String(),
      });
      print('✅ Activity data synced to cloud');
    } catch (e) {
      print('❌ Failed to sync activity data: $e');
      _failedActivityQueue.add(activityData);
    }
  }

  Future<void> retryFailedUploads() async {
    // Retry GPS uploads
    for (final data in List<Map<String, dynamic>>.from(_failedGpsQueue)) {
      try {
        await uploadGpsData(data);
        _failedGpsQueue.remove(data);
      } catch (_) {}
    }
    // Retry Activity uploads
    for (final data in List<Map<String, dynamic>>.from(_failedActivityQueue)) {
      try {
        await uploadActivityData(data);
        _failedActivityQueue.remove(data);
      } catch (_) {}
    }
  }

  Future<bool> tryUpdateCloudData(
    String docId,
    Map<String, dynamic> newData,
  ) async {
    final doc = await _db.collection('user_profile').doc(docId).get();
    if (doc.exists && doc.data() != null) {
      final remoteTimestamp =
          DateTime.tryParse(doc.data()!['updatedAt'] ?? '') ?? DateTime(2000);
      final localTimestamp =
          DateTime.tryParse(newData['updatedAt'] ?? '') ?? DateTime(2000);
      if (remoteTimestamp.isAfter(localTimestamp)) {
        // Conflict detected, handle merge or prompt user
        return false;
      }
    }
    await _db.collection('user_profile').doc(docId).set(newData);
    return true;
  }
}
