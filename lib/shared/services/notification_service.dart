import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationQuickAction { quickWeight }

class NotificationQuickActionNotifier
    extends StateNotifier<NotificationQuickAction?> {
  NotificationQuickActionNotifier() : super(null);

  void trigger(NotificationQuickAction action) => state = action;

  void clear() => state = null;
}

final notificationQuickActionProvider =
    StateNotifierProvider<
      NotificationQuickActionNotifier,
      NotificationQuickAction?
    >((ref) => NotificationQuickActionNotifier());

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(ref);
  service.initialize();
  return service;
});

class NotificationService {
  NotificationService(this._ref);

  final Ref _ref;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _permissionsGranted = false;

  static const String _quickWeightChannelId = 'quick_weight_channel';
  static const String _quickWeightChannelName = 'Peso rápido';
  static const String _quickWeightPayload = 'quick_weight_payload';
  static const String _quickWeightActionId = 'quick_weight_action';

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    bool granted = true;

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      final bool? enabled = await androidPlugin.areNotificationsEnabled();
      if (enabled == null || !enabled) {
        final bool? result = await androidPlugin
            .requestNotificationsPermission();
        granted = granted && (result ?? false);
      }
    }

    _permissionsGranted = granted;
  }

  Future<bool> showQuickWeightShortcut() async {
    await initialize();
    if (!_permissionsGranted) {
      await _requestPermissions();
    }
    if (!_permissionsGranted) {
      return false;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _quickWeightChannelId,
          _quickWeightChannelName,
          channelDescription:
              'Acceso rápido para registrar una nueva medición de peso.',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Registro rápido de peso',
          category: AndroidNotificationCategory.reminder,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              _quickWeightActionId,
              'Registrar peso',
              showsUserInterface: true,
            ),
          ],
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      1001,
      'Registrar peso ahora',
      'Toca para abrir el registro rápido de peso.',
      notificationDetails,
      payload: _quickWeightPayload,
    );
    return true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    final bool isQuickWeightAction =
        response.payload == _quickWeightPayload ||
        response.actionId == _quickWeightActionId;
    if (!isQuickWeightAction) {
      return;
    }
    _ref
        .read(notificationQuickActionProvider.notifier)
        .trigger(NotificationQuickAction.quickWeight);
  }
}
