import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    print('Firebase Messaging Token: $token');
    await _firebaseMessaging.subscribeToTopic('all');
    // TODO: Сохранить токен на сервере
  }
}
