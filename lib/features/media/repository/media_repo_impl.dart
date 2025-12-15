import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:lite_x/features/media/models/shared.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/media/models/confirm_upload_model.dart';
import 'package:lite_x/features/media/models/request_upload_model.dart';
import 'package:lite_x/features/media/repository/media_repo.dart';

class MediaRepoImpL implements MediaRepo {
  Dio _dio;
  MediaRepoImpL(Dio d) : _dio = d {}

  Future<Either<Failure, RequestUploadModel>> requestUpload(
    String fileName,
    String fileType,
  ) async {
    try {
      final res = await _dio.post(
        "api/media/upload-request",
        data: {"fileName": fileName, "contentType": fileType},
      );
      final RequestUploadModel model = RequestUploadModel.fromJson(res.data);
      return (Right(model));
    } catch (e) {
      return Left(Failure("can't request upload media"));
    }
  }

  Future<Either<Failure, ConfirmUploadModel>> confirmUpload(
    String keyName,
  ) async {
    try {
      final encodedKeyName = Uri.encodeComponent(keyName);
      final res = await _dio.post("api/media/confirm-upload/$encodedKeyName");
      final ConfirmUploadModel model = ConfirmUploadModel.fromJson(res.data);
      return (Right(model));
    } catch (e) {
      return Left(Failure("can't confirm upload media"));
    }
  }

  Future<Either<Failure, void>> upload(String uploadUrl, File mediaFile, {Dio? dio}) async {
    try {
      List<int> fileBytes = await mediaFile.readAsBytes();
      final localDio = dio ?? Dio();
      final res = await localDio.put(
        uploadUrl,
        data: Stream.fromIterable([fileBytes]),
        options: Options(
          headers: {
            'Content-Type': getMediaType(mediaFile.path),
            'Content-Length': fileBytes.length,
          },
        ),
        onSendProgress: (int sent, int total) {
          double progress = (sent / total) * 100;
          print('Upload progress: ${progress.toStringAsFixed(2)}%');
        },
      );
      if (res.statusCode == 200 || res.statusCode == 201) return Right(());
      return Left(Failure("can't upload media"));
    } catch (e) {
      return Left(Failure("can't upload media"));
    }
  }

  Future<Either<Failure, String>> getMediaUrl(String id) async {
    try {
      final res = await _dio.get("api/media/download-request/$id");
      return Right((res.data["url"] ?? ""));
    } catch (e) {
      return Left(Failure("can't download media"));
    }
  }
}

//   Future<Either<AppFailure, Map<String, dynamic>>> uploadProfilePhoto({
//     required PickedImage pickedImage,
//   }) async {
//     if (pickedImage.file == null) {
//       return left(AppFailure(message: 'No file selected'));
//     }
//     final file = pickedImage.file!;
//     final fileName = pickedImage.name;
//     final fileType = _getMediaType(file.path);
//     try {
//       final requestResponse = await _dio.post(
//         'api/media/upload-request',
//         data: {'fileName': fileName, 'contentType': fileType},
//       );

//       final String presignedUrl = requestResponse.data['url'];
//       final String keyName = requestResponse.data['keyName'];
//       final fileBytes = await file.readAsBytes();

//       final newDio = Dio(
//         BaseOptions(
//           headers: {
//             'Content-Type': fileType,
//             'Content-Length': fileBytes.length,
//           },
//         ),
//       );

//       await newDio.put(presignedUrl, data: Stream.fromIterable([fileBytes]));

//       final confirmResponse = await _dio.post(
//         'api/media/confirm-upload/$keyName',
//       );

//       final mediaId = confirmResponse.data['newMedia']['id'].toString();

//       final newMediaKey = confirmResponse.data['newMedia']['keyName'] as String;
//       print("MEDIA ID AFTER UPLOAD: $mediaId");

//       return right({'mediaId': mediaId, 'keyName': newMediaKey});
//     } on DioException catch (e) {
//       return left(AppFailure(message: 'Upload failed'));
//     } catch (e) {
//       return left(AppFailure(message: e.toString()));
//     }
//   }
