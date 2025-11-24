class AppFailure {
  final String message;

  const AppFailure({this.message = "Unexpected error occurred"});

  @override
  String toString() => 'AppFailure(message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFailure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
