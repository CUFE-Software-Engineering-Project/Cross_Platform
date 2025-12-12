import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';

void main() {
  group("AuthState Factory Constructors", () {
    test("unauthenticated factory should create correct state", () {
      final s = AuthState.unauthenticated("msg");
      expect(s.type, AuthStateType.unauthenticated);
      expect(s.message, "msg");
    });

    test("loading factory should create loading state", () {
      final s = AuthState.loading();
      expect(s.type, AuthStateType.loading);
      expect(s.message, isNull);
    });

    test("authenticated factory should create authenticated state", () {
      final s = AuthState.authenticated("login ok");
      expect(s.type, AuthStateType.authenticated);
      expect(s.message, "login ok");
    });

    test("awaitingVerification factory works", () {
      final s = AuthState.awaitingVerification("verify");
      expect(s.type, AuthStateType.awaitingVerification);
      expect(s.message, "verify");
    });

    test("verified factory works", () {
      final s = AuthState.verified("done");
      expect(s.type, AuthStateType.verified);
      expect(s.message, "done");
    });

    test("awaitingPassword factory works", () {
      final s = AuthState.awaitingPassword("pass required");
      expect(s.type, AuthStateType.awaitingPassword);
      expect(s.message, "pass required");
    });

    test("success factory works", () {
      final s = AuthState.success("ok");
      expect(s.type, AuthStateType.success);
      expect(s.message, "ok");
    });

    test("error factory should set previousType when passed", () {
      final s = AuthState.error("failed", previous: AuthStateType.loading);

      expect(s.type, AuthStateType.error);
      expect(s.message, "failed");
      expect(s.previousType, AuthStateType.loading);
    });
  });

  group("AuthState getters", () {
    test("isLoading returns true only for loading", () {
      final s = AuthState.loading();
      expect(s.isLoading, true);
    });

    test("isAuthenticated returns true only for authenticated", () {
      final s = AuthState.authenticated();
      expect(s.isAuthenticated, true);
    });

    test("isAwaitingPassword returns true only for awaitingPassword", () {
      final s = AuthState.awaitingPassword();
      expect(s.isAwaitingPassword, true);
    });

    test("hasError returns true only for error", () {
      final s = AuthState.error("bad");
      expect(s.hasError, true);
    });
  });

  group("copyWith", () {
    test("copyWith overrides provided fields", () {
      final s1 = AuthState.authenticated("msg1");

      final s2 = s1.copyWith(
        type: AuthStateType.success,
        message: "updated",
        previousType: AuthStateType.loading,
      );

      expect(s2.type, AuthStateType.success);
      expect(s2.message, "updated");
      expect(s2.previousType, AuthStateType.loading);
    });

    test("copyWith keeps old fields when not overridden", () {
      final s1 = AuthState.authenticated("msg1");

      final s2 = s1.copyWith();

      expect(s2.type, s1.type);
      expect(s2.message, s1.message);
      expect(s2.previousType, s1.previousType);
    });
  });

  group("resetAfterError", () {
    test("should restore previousType when available", () {
      final s = AuthState.error("failed", previous: AuthStateType.loading);

      final restored = s.resetAfterError();

      expect(restored.type, AuthStateType.loading);
    });

    test("should return unauthenticated when no previousType", () {
      final s = AuthState.error("failed");

      final restored = s.resetAfterError();

      expect(restored.type, AuthStateType.unauthenticated);
    });
  });

  group("toString", () {
    test("should return formatted string", () {
      final s = AuthState.authenticated("ok");

      expect(
        s.toString(),
        'AuthState(type: AuthStateType.authenticated, message: ok, previousType: null)',
      );
    });
  });
}
