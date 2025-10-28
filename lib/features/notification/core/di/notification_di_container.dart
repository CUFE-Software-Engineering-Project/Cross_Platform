import 'package:dio/dio.dart';
import '../interfaces/notification_repository_interface.dart';
import '../interfaces/notification_service_interface.dart';
import '../interfaces/notification_data_source_interface.dart';
import '../interfaces/notification_socket_interface.dart';
import '../../models/notification_api_data_source.dart';
import '../../models/notification_socket_data_source.dart';
import '../../repositories/notification_repository_impl.dart';
import '../../repositories/notification_service_impl.dart';
import '../../config/notification_config.dart';

/// Dependency Injection Container for notification system
/// Follows Dependency Inversion Principle (DIP)
class NotificationDIContainer {
  static final NotificationDIContainer _instance = NotificationDIContainer._internal();
  factory NotificationDIContainer() => _instance;
  NotificationDIContainer._internal();

  // Lazy singletons
  Dio? _dio;
  INotificationDataSource? _dataSource;
  INotificationSocket? _socket;
  INotificationRepository? _repository;
  INotificationService? _service;

  /// Get Dio instance
  Dio get dio {
    _dio ??= Dio(BaseOptions(
      baseUrl: NotificationConfig.baseUrl,
      connectTimeout: NotificationConfig.requestTimeout,
      receiveTimeout: NotificationConfig.requestTimeout,
    ));
    return _dio!;
  }

  /// Get notification data source
  INotificationDataSource get dataSource {
    _dataSource ??= NotificationApiDataSource(dio: dio);
    return _dataSource!;
  }

  /// Get notification socket
  INotificationSocket get socket {
    _socket ??= NotificationSocketDataSource();
    return _socket!;
  }

  /// Get notification repository
  INotificationRepository get repository {
    _repository ??= NotificationRepositoryImpl(
      dataSource: dataSource,
      socket: socket,
    );
    return _repository!;
  }

  /// Get notification service
  INotificationService get service {
    _service ??= NotificationServiceImpl(repository: repository);
    return _service!;
  }

  /// Reset all dependencies (useful for testing)
  void reset() {
    _dio?.close();
    _dio = null;
    _dataSource = null;
    _socket = null;
    _repository = null;
    _service = null;
  }
}
