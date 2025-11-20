import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/media/models/confirm_upload_model.dart';
import 'package:lite_x/features/media/models/request_upload_model.dart';

abstract class MediaRepo {
  Future<Either<Failure, RequestUploadModel>> requestUpload(String fileName, String fileType);
  Future<Either<Failure, void>> upload(String uploadUrl, File mediaFile);
  Future<Either<Failure, ConfirmUploadModel>> confirmUpload(String keyName);
  Future<Either<Failure, String>> getMediaUrl(String id);
}