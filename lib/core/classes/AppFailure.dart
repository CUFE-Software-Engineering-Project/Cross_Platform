class AppFailure {
  final String message;

  AppFailure({this.message = "UnExpected error occured"});

  @override
  String toString() => 'AppFailure(message: $message)';
}
