import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dsp_base/convenience_imports.dart';
import 'package:get/get.dart';

import 'package:waternudge/controller/auth_controller.dart';

/// Persists user feedback to Firestore (collection `feedbacks`).
///
/// Every submission is keyed by the device id; when the user is signed in the
/// Firebase user id (and email) are attached as well. Screenshot attachments are
/// NOT uploaded yet — only their count is recorded; file upload will move to a
/// dedicated backend later.
class FeedbackService {
  FeedbackService._();

  static final FeedbackService instance = FeedbackService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns immediately. All metadata gathering and the Firestore write run in
  /// the background — the UI never waits on device channels or a network ack.
  /// Firestore's local cache makes the write durable the moment it's queued.
  Future<void> submit({
    required String category,
    required String subject,
    required String message,
    List<String> attachmentPaths = const [],
  }) async {
    unawaited(
      _persist(
        category: category,
        subject: subject,
        message: message,
        attachmentCount: attachmentPaths.length,
      ),
    );
  }

  Future<void> _persist({
    required String category,
    required String subject,
    required String message,
    required int attachmentCount,
  }) async {
    String deviceId = '';
    try {
      deviceId = await DeviceUtils.getDeviceId().timeout(
        const Duration(seconds: 3),
        onTimeout: () => '',
      );
    } catch (_) {
      deviceId = '';
    }

    String? userId;
    String? userEmail;
    if (Get.isRegistered<AuthController>()) {
      final auth = AuthController.to;
      if (auth.isLoggedIn) {
        userId = auth.user.value?.uid;
        userEmail = auth.email.isNotEmpty ? auth.email : null;
      }
    }

    String appVersion = '';
    String appBuild = '';
    try {
      final info = await PackageInfo.fromPlatform().timeout(
        const Duration(seconds: 3),
      );
      appVersion = info.version;
      appBuild = info.buildNumber;
    } catch (_) {
      // best-effort metadata
    }

    try {
      await _db.collection('feedbacks').add({
        'deviceId': deviceId,
        'userId': userId,
        'userEmail': userEmail,
        'category': category,
        'subject': subject.trim(),
        'message': message.trim(),
        'attachmentCount': attachmentCount,
        'platform': Platform.operatingSystem,
        'appVersion': appVersion,
        'appBuild': appBuild,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      CommLogger.e('Feedback Firestore write failed: $e');
    }
  }
}
