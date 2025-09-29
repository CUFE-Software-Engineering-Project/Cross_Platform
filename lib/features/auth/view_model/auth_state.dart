enum AuthStateType {
  initial,
  loading,
  success,
  error,
  unauthenticated,
  authenticated,
  verified,
  unverified,
}

class AuthState {
  final AuthStateType type;
  final String? message;

  const AuthState({required this.type, this.message});

  factory AuthState.initial() => const AuthState(type: AuthStateType.initial);

  factory AuthState.loading() => const AuthState(type: AuthStateType.loading);

  factory AuthState.success([String? msg]) =>
      AuthState(type: AuthStateType.success, message: msg);

  factory AuthState.error(String msg) =>
      AuthState(type: AuthStateType.error, message: msg);

  factory AuthState.unauthenticated([String? msg]) =>
      AuthState(type: AuthStateType.unauthenticated, message: msg);

  factory AuthState.authenticated([String? msg]) =>
      AuthState(type: AuthStateType.authenticated, message: msg);

  factory AuthState.verified([String? msg]) =>
      AuthState(type: AuthStateType.verified, message: msg);

  factory AuthState.unverified([String? msg]) =>
      AuthState(type: AuthStateType.unverified, message: msg);

  AuthState copyWith({AuthStateType? type, String? message}) {
    return AuthState(type: type ?? this.type, message: message ?? this.message);
  }

  @override
  String toString() => 'AuthState(type: $type, message: $message)';
}
