import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'auth_view_model.g.dart';

@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() {
    return AuthState.unauthenticated();
  }
}
