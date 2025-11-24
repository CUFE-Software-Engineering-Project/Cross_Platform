import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'tokenStream.g.dart';

@Riverpod(keepAlive: true)
Stream<TokensModel?> tokenStream(Ref ref) {
  final authLocalRepository = ref.watch(authLocalRepositoryProvider);
  return authLocalRepository.tokenStream;
}
