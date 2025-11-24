import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:lite_x/features/auth/repositories/auth_remote_repository.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<ProfileRepo>(),
  MockSpec<AuthViewModel>(),
  MockSpec<AuthRemoteRepository>(),
  MockSpec<AuthLocalRepository>(),
])
void main() {}
