enum AuthStateType {
  unauthenticated,
  loading,
  authenticated,
  awaitingVerification,
  verified,
  awaitingPassword,
  success,
  error,
}

class AuthState {
  final AuthStateType type;
  final String? message;
  final AuthStateType? previousType;

  const AuthState({required this.type, this.message, this.previousType});

  factory AuthState.unauthenticated([String? msg]) =>
      AuthState(type: AuthStateType.unauthenticated, message: msg);

  factory AuthState.loading() => const AuthState(type: AuthStateType.loading);

  factory AuthState.authenticated([String? msg]) =>
      AuthState(type: AuthStateType.authenticated, message: msg);

  factory AuthState.awaitingVerification([String? msg]) =>
      AuthState(type: AuthStateType.awaitingVerification, message: msg);

  factory AuthState.verified([String? msg]) =>
      AuthState(type: AuthStateType.verified, message: msg);

  factory AuthState.awaitingPassword([String? msg]) =>
      AuthState(type: AuthStateType.awaitingPassword, message: msg);

  factory AuthState.success([String? msg]) =>
      AuthState(type: AuthStateType.success, message: msg);

  factory AuthState.error(String msg, {AuthStateType? previous}) => AuthState(
    type: AuthStateType.error,
    message: msg,
    previousType: previous,
  );

  AuthState resetAfterError() {
    if (previousType != null) {
      return AuthState(type: previousType!);
    }
    return AuthState.unauthenticated();
  }

  AuthState copyWith({
    AuthStateType? type,
    String? message,
    AuthStateType? previousType,
  }) {
    return AuthState(
      type: type ?? this.type,
      message: message ?? this.message,
      previousType: previousType ?? this.previousType,
    );
  }

  bool get isLoading => type == AuthStateType.loading;
  bool get isAuthenticated => type == AuthStateType.authenticated;
  bool get isAwaitingPassword => type == AuthStateType.awaitingPassword;
  bool get hasError => type == AuthStateType.error;

  @override
  String toString() =>
      'AuthState(type: $type, message: $message, previousType: $previousType)';
}
