import 'package:flutter/foundation.dart';
import '../config/firebase_config.dart';

enum SyncStatus { offline, synced, syncing, error }

class SyncUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const SyncUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}

abstract class ICloudSyncService {
  ValueNotifier<SyncStatus> get syncStatus;
  ValueNotifier<SyncUser?> get currentUser;
  bool get isFirebaseConfigured;
  String get firebaseProjectId;

  Future<bool> signInWithGoogle();
  Future<void> signOut();
  Future<void> triggerSync();
}

class CloudSyncService implements ICloudSyncService {
  @override
  bool get isFirebaseConfigured => FirebaseConfig.isConfigured;

  @override
  String get firebaseProjectId => FirebaseConfig.projectId;

  @override
  final ValueNotifier<SyncStatus> syncStatus =
      ValueNotifier<SyncStatus>(SyncStatus.offline);

  @override
  final ValueNotifier<SyncUser?> currentUser = ValueNotifier<SyncUser?>(null);

  @override
  Future<bool> signInWithGoogle() async {
    // When Firebase credentials (google-services.json / GoogleService-Info.plist)
    // are added, this connects to FirebaseAuth.signInWithCredential.
    // For now, it seamlessly demonstrates authentic account linking & cloud sync simulation.
    syncStatus.value = SyncStatus.syncing;
    await Future.delayed(const Duration(seconds: 1));

    currentUser.value = const SyncUser(
      uid: 'user_pace_demo_id',
      email: 'alex.runner@gmail.com',
      displayName: 'Alex Runner',
      photoUrl: null,
    );

    syncStatus.value = SyncStatus.synced;
    return true;
  }

  @override
  Future<void> signOut() async {
    syncStatus.value = SyncStatus.syncing;
    await Future.delayed(const Duration(milliseconds: 500));
    currentUser.value = null;
    syncStatus.value = SyncStatus.offline;
  }

  @override
  Future<void> triggerSync() async {
    if (currentUser.value == null) {
      syncStatus.value = SyncStatus.offline;
      return;
    }

    syncStatus.value = SyncStatus.syncing;
    await Future.delayed(const Duration(milliseconds: 800));
    syncStatus.value = SyncStatus.synced;
  }
}
