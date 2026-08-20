
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // ============================================================
    // 1. CONFIGURAR NOTIFICACIONES LOCALES
    // ============================================================

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
    );

    // ============================================================
    // 2. CREAR CANAL DE NOTIFICACIONES
    // ============================================================

    const AndroidNotificationChannel channel =
        AndroidNotificationChannel(
      'huellitas_notifications',
      'Notificaciones Huellitas',
      description:
          'Notificaciones de denuncias y actividad de Huellitas',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // ============================================================
    // 3. SOLICITAR PERMISOS FCM
    // ============================================================

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ============================================================
    // 4. OBTENER TOKEN
    // ============================================================

    final token = await _firebaseMessaging.getToken();

    print('FCM TOKEN: $token');

    // ============================================================
    // 5. MENSAJES CON LA APP ABIERTA
    // ============================================================

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print(
          'Nueva notificación: '
          '${message.notification?.title}',
        );

        showNotification(
          title: message.notification?.title ??
              'Huellitas',
          body: message.notification?.body ??
              'Tienes una nueva notificación',
        );
      },
    );
  }

  // ==============================================================
  // MOSTRAR NOTIFICACIÓN LOCAL
  // ==============================================================

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'huellitas_notifications',
      'Notificaciones Huellitas',
      channelDescription:
          'Notificaciones de denuncias y actividad de Huellitas',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}

/*--Notificaciones firebase--*/

/*--import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {

  final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  Future<void> initialize() async {

    // PERMISOS
    await _firebaseMessaging
        .requestPermission();

    // TOKEN DEVICE
    String? token =
        await _firebaseMessaging.getToken();

    print('FCM TOKEN: $token');

    // FOREGROUND
    FirebaseMessaging.onMessage.listen(

      (RemoteMessage message) {

        print(
          'Nueva notificación: '
          '${message.notification?.title}',
        );
      },
    );
  }
}--*/