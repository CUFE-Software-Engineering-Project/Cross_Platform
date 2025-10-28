import 'package:dio/dio.dart';

import '../config/notification_config.dart';
import '../core/interfaces/notification_data_source_interface.dart';
import 'notification_model.dart';

/// REST API data source for notifications
class NotificationApiDataSource implements INotificationDataSource {
  final Dio _dio;

  NotificationApiDataSource({required Dio dio}) : _dio = dio;

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  @override
  Future<List<NotificationModel>> fetchNotifications(String token) async {
    try {
      final response = await _dio.get(
        NotificationApiUrls.getNotifications(),
        options: Options(headers: _headers(token)),
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => NotificationModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      }
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .map((e) => NotificationModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<int> getUnseenCount(String token) async {
    try {
      final response = await _dio.get(
        NotificationApiUrls.getUnseenCount(),
        options: Options(headers: _headers(token)),
      );
      final data = response.data;
      if (data is Map && data['count'] != null) {
        return int.tryParse(data['count'].toString()) ?? 0;
      }
      if (data is num) return data.toInt();
      return 0;
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch unseen count: $e');
    }
  }

  @override
  Future<void> markAsRead(String token, String notificationId) async {
    try {
      await _dio.patch(
        NotificationApiUrls.markAsRead(notificationId),
        options: Options(headers: _headers(token)),
      );
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getUnseenNotifications(String token) async {
    try {
      final response = await _dio.get(
        NotificationApiUrls.getUnseenNotifications(),
        options: Options(headers: _headers(token)),
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => NotificationModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      }
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .map((e) => NotificationModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch unseen notifications: $e');
    }
  }

  @override
  Future<NotificationModel> addNotification(
    String token,
    NotificationInputModel notificationInput,
  ) async {
    try {
      final response = await _dio.post(
        NotificationApiUrls.getNotifications(),
        data: notificationInput.toJson(),
        options: Options(headers: _headers(token)),
      );
      return NotificationModel.fromJson(
        (response.data as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add notification: $e');
    }
  }
}


