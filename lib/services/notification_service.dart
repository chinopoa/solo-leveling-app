import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/quest.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Notification settings keys
  static const String _dailyQuestReminderKey = 'notification_daily_quest_reminder';
  static const String _scheduledQuestKey = 'notification_scheduled_quest';
  static const String _nutritionReminderKey = 'notification_nutrition_reminder';
  static const String _dailyReminderTimeKey = 'notification_daily_reminder_time';

  // Notification IDs
  static const int _dailyQuestReminderId = 1000;
  static const int _nutritionBreakfastId = 2000;
  static const int _nutritionLunchId = 2001;
  static const int _nutritionDinnerId = 2002;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  // Request permissions for iOS
  Future<bool> requestPermissions() async {
    final iOS = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return iOS ?? false;
  }

  // Check if notifications are permitted
  Future<bool> areNotificationsEnabled() async {
    final iOS = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();

    return iOS?.isEnabled ?? false;
  }

  // Settings getters/setters
  Future<bool> getDailyQuestReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyQuestReminderKey) ?? false;
  }

  Future<void> setDailyQuestReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyQuestReminderKey, enabled);

    if (enabled) {
      await scheduleDailyQuestReminder();
    } else {
      await cancelDailyQuestReminder();
    }
  }

  Future<bool> getScheduledQuestNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_scheduledQuestKey) ?? false;
  }

  Future<void> setScheduledQuestNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_scheduledQuestKey, enabled);
  }

  Future<bool> getNutritionReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_nutritionReminderKey) ?? false;
  }

  Future<void> setNutritionReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nutritionReminderKey, enabled);

    if (enabled) {
      await scheduleNutritionReminders();
    } else {
      await cancelNutritionReminders();
    }
  }

  Future<TimeOfDay> getDailyReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('${_dailyReminderTimeKey}_hour') ?? 9;
    final minute = prefs.getInt('${_dailyReminderTimeKey}_minute') ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_dailyReminderTimeKey}_hour', time.hour);
    await prefs.setInt('${_dailyReminderTimeKey}_minute', time.minute);

    // Reschedule if enabled
    if (await getDailyQuestReminderEnabled()) {
      await scheduleDailyQuestReminder();
    }
  }

  // Schedule daily quest reminder
  Future<void> scheduleDailyQuestReminder() async {
    await _notifications.cancel(_dailyQuestReminderId);

    final time = await getDailyReminderTime();
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      _dailyQuestReminderId,
      'Daily Quests Await!',
      'Complete your daily quests to level up, Hunter!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'daily_quest_channel',
          'Daily Quest Reminders',
          channelDescription: 'Reminds you to complete daily quests',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  Future<void> cancelDailyQuestReminder() async {
    await _notifications.cancel(_dailyQuestReminderId);
  }

  // Schedule notification for a scheduled quest
  Future<void> scheduleQuestNotification(Quest quest) async {
    if (quest.scheduledDate == null) return;
    if (!await getScheduledQuestNotificationsEnabled()) return;

    final scheduledDateTime = DateTime(
      quest.scheduledDate!.year,
      quest.scheduledDate!.month,
      quest.scheduledDate!.day,
      9, // 9 AM on the scheduled day
      0,
    );

    // Don't schedule if it's in the past
    if (scheduledDateTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      quest.id.hashCode,
      'Quest Now Available!',
      'Your quest "${quest.title}" is now active. Time to hunt!',
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'scheduled_quest_channel',
          'Scheduled Quest Notifications',
          channelDescription: 'Notifies when scheduled quests become active',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'quest:${quest.id}',
    );
  }

  Future<void> cancelQuestNotification(Quest quest) async {
    await _notifications.cancel(quest.id.hashCode);
  }

  // Schedule nutrition reminders (breakfast, lunch, dinner)
  Future<void> scheduleNutritionReminders() async {
    await cancelNutritionReminders();

    // Breakfast reminder at 8 AM
    await _scheduleNutritionReminder(
      id: _nutritionBreakfastId,
      title: 'Log Your Breakfast',
      body: 'Don\'t forget to track what you ate this morning!',
      hour: 8,
      minute: 0,
    );

    // Lunch reminder at 1 PM
    await _scheduleNutritionReminder(
      id: _nutritionLunchId,
      title: 'Log Your Lunch',
      body: 'Time to track your lunch, Hunter!',
      hour: 13,
      minute: 0,
    );

    // Dinner reminder at 7 PM
    await _scheduleNutritionReminder(
      id: _nutritionDinnerId,
      title: 'Log Your Dinner',
      body: 'Remember to log your dinner before the day ends!',
      hour: 19,
      minute: 0,
    );
  }

  Future<void> _scheduleNutritionReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'nutrition_channel',
          'Nutrition Reminders',
          channelDescription: 'Reminds you to log your meals',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  Future<void> cancelNutritionReminders() async {
    await _notifications.cancel(_nutritionBreakfastId);
    await _notifications.cancel(_nutritionLunchId);
    await _notifications.cancel(_nutritionDinnerId);
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Show immediate notification (for testing)
  Future<void> showTestNotification() async {
    await _notifications.show(
      0,
      'Test Notification',
      'Notifications are working!',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'For testing notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
