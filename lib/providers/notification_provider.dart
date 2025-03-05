import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationProvider with ChangeNotifier {
  NotificationProvider() {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await AwesomeNotifications().initialize(
      null, // null means using default app icon
      [
        NotificationChannel(
          channelKey: 'blood_donation_channel',
          channelName: 'Blood Donation Notifications',
          channelDescription: 'Notifications for blood donation requests',
          defaultColor: Colors.red,
          ledColor: Colors.red,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableVibration: true,
          playSound: true,
        )
      ],
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required int id,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'blood_donation_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        color: Colors.red,
      ),
    );
  }

  Future<void> showUrgentRequestNotification({
    required String title,
    required String body,
    required int id,
  }) async {
    // إشعار عاجل
    await showNotification(
      id: id,
      title: title,
      body: body,
    );
  }

  Future<void> showDonationRequestNotification({
    required String title,
    required String body,
    required int id,
  }) async {
    // إشعار طلب تبرع
    await showNotification(
      id: id,
      title: title,
      body: body,
    );
  }

  Future<void> showDonationThankYouNotification({
    required String title,
    required String body,
    required int id,
  }) async {
    // إشعار شكر للمتبرع
    await showNotification(
      id: id,
      title: title,
      body: body,
    );
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> requestPermission() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  void dispose() {
    AwesomeNotifications().dispose();
    super.dispose();
  }
}
