// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokenStream.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tokenStream)
const tokenStreamProvider = TokenStreamProvider._();

final class TokenStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<TokensModel?>,
          TokensModel?,
          Stream<TokensModel?>
        >
    with $FutureModifier<TokensModel?>, $StreamProvider<TokensModel?> {
  const TokenStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStreamHash();

  @$internal
  @override
  $StreamProviderElement<TokensModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TokensModel?> create(Ref ref) {
    return tokenStream(ref);
  }
}

String _$tokenStreamHash() => r'090d39c047d45d466fc606b422a1f0c4f538a110';
