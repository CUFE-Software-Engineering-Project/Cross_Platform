import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:lite_x/features/media/download_media.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';
import 'package:lite_x/features/settings/models/muted_users_response.dart';
import 'settings_repo.dart';

/// Mock-data implementation while backend endpoints are being finalized.
/// Keeps the same interface so swapping to real HTTP later is trivial.
class SettingsRepoImpl implements SettingsRepo {
  final Dio _dio; // kept for future parity, not used in mock
  SettingsRepoImpl(this._dio);

  // In-memory state to simulate server behavior
  final List<UserModel> _blocked = [
    UserModel(
      displayName: 'CentreGoals.',
      userName: 'centregoals',
      image: '',
      bio: 'An all-round coverage of European football',
      isVerified: true,
    ),
    UserModel(
      displayName: 'Polymarket',
      userName: 'Polymarket',
      image: '',
      bio: "The world's largest prediction market.",
      isVerified: true,
    ),
  ];

  final List<UserModel> _muted = [
    UserModel(
      displayName: 'Hasan Ismaik',
      userName: 'HasanIsmaik',
      image: '',
      bio: 'Businessman, writer, researcher',
      isVerified: true,
    ),
    UserModel(
      displayName: 'OmoOgaTea...',
      userName: 'eraytee7',
      image: '',
      bio: 'Environmental geoscientist (Ph.D) || Unilorin, UI & CIU Al...',
      isVerified: true,
    ),
  ];

  SettingsModel _settingsFor(String username) =>
      SettingsModel.initial(username);

  @override
  Future<Either<Failure, SettingsModel>> getSettings(String username) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return Right(_settingsFor(username));
  }

  @override
  Future<Either<Failure, SettingsModel>> updateSettings({
    required SettingsModel newModel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return Right(newModel.copyWith(lastUpdated: DateTime.now()));
  }

  @override
  Future<Either<Failure, List<UserModel>>> getBlockedAccounts(
    String username,
  ) async {
    try {
      final res = await _dio.get("api/blocks");
      final List<dynamic> jsonList = res.data["users"];
      for (int i = 0; i < jsonList.length; i++) {
        final String photoId = jsonList[i]?["photo"] ?? "";
        final photoUrl = await getMediaUrls([photoId]);
        jsonList[i]["photo"] = photoUrl[0];
      }
      final List<UserModel> users = jsonList.map((json) {
        final Map<String, dynamic> jsonMap = json as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      }).toList();
      return Right(users);
    } catch (e) {
      return Left(Failure("Can't get Blocked users, try again later.."));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getMutedAccounts(
    String username,
  ) async {
    try {
      final res = await _dio.get("api/mutes");
      final List<dynamic> jsonList = res.data["users"];
      for (int i = 0; i < jsonList.length; i++) {
        final String photoId = jsonList[i]?["photo"] ?? "";
        final photoUrl = await getMediaUrls([photoId]);
        jsonList[i]["photo"] = photoUrl[0];
      }
      final List<UserModel> users = jsonList.map((json) {
        final Map<String, dynamic> jsonMap = json as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      }).toList();

      return Right(users);
    } catch (e) {
      return Left(Failure("Can't get muted users, try again later.."));
    }
  }

  @override
  Future<Either<Failure, MutedUsersResponse>> fetchMutedAccounts({
    int limit = 30,
    String? cursor,
  }) async {
    try {
      final response = await _dio.get(
        'api/mutes',
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final data = MutedUsersResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Right(data);
    } catch (e) {
      return Left(Failure('Failed to fetch muted accounts'));
    }
  }

  @override
  Future<Either<Failure, MutedUsersResponse>> fetchBlockedAccounts({
    int limit = 30,
    String? cursor,
  }) async {
    try {
      final response = await _dio.get(
        'api/blocks',
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final data = MutedUsersResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Right(data);
    } catch (e) {
      return Left(Failure('Failed to fetch blocked accounts'));
    }
  }

  @override
  Future<Either<Failure, void>> blockAccount(String username) async {
    try {
      await _dio.post("api/blocks/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't block user"));
    }
  }

  @override
  Future<Either<Failure, void>> unblockAccount(String username) async {
    try {
      await _dio.delete("api/blocks/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't unblock user"));
    }
  }

  @override
  Future<Either<Failure, void>> muteAccount(String username) async {
    try {
      await _dio.post("api/mutes/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't mute user"));
    }
  }

  @override
  Future<Either<Failure, void>> unMuteAccount(String username) async {
    try {
      await _dio.delete("api/mutes/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't unmute user"));
    }
  }

  @override
  Future<Either<Failure, void>> followUser(String username) async {
    try {
      await _dio.post("api/followers/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't follow user"));
    }
  }

  Future<Either<Failure, void>> unFollowUser(String username) async {
    try {
      await _dio.delete("api/followers/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't unfollow user"));
    }
  }
}
