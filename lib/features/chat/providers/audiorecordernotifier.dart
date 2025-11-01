import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lite_x/core/classes/AudioRecorderUtil.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

part 'audiorecordernotifier.g.dart';

enum RecorderStatus { idle, recording, reviewing }

@riverpod
class AudioRecorderNotifier extends _$AudioRecorderNotifier {
  final _recorder = AudioRecorderUtil();
  DateTime? _recordingStartTime;
  Duration? _actualRecordingDuration;
  static const maxDuration = Duration(seconds: 140);

  @override
  AudioRecorderState build() => const AudioRecorderState();

  Future<bool> startRecording() async {
    final success = await _recorder.startRecording();
    if (success) {
      _recordingStartTime = DateTime.now();
      _actualRecordingDuration = null;
      state = state.copyWith(
        status: RecorderStatus.recording,
        remainingDuration: maxDuration, // 140 seconds
      );
    }
    return success;
  }

  Future<void> stopRecording() async {
    if (state.status != RecorderStatus.recording) return;

    final path = await _recorder.stopRecording();
    if (path == null) {
      await _resetToIdle();
      return;
    }
    final elapsed = _recordingStartTime != null
        ? DateTime.now().difference(_recordingStartTime!)
        : Duration.zero;

    _actualRecordingDuration = elapsed;

    state = state.copyWith(
      status: RecorderStatus.reviewing,
      recordingPath: path,
      remainingDuration: elapsed,
    );
    _recordingStartTime = null;
  }

  Future<void> cancelRecording() async {
    if (state.status != RecorderStatus.recording) return;

    await _recorder.cancelRecording();
    await _resetToIdle();
    _recordingStartTime = null;
    _actualRecordingDuration = null;
  }

  Future<void> cancelReview() async {
    if (state.status != RecorderStatus.reviewing) return;

    await _deleteRecordingFile();
    await _resetToIdle();
    _actualRecordingDuration = null;
  }

  String? sendRecording() {
    if (state.status != RecorderStatus.reviewing) return null;

    final path = state.recordingPath;
    _resetToIdle();
    _actualRecordingDuration = null;
    return path;
  }

  void updateRecordingDuration() {
    if (_recordingStartTime == null ||
        state.status != RecorderStatus.recording) {
      return;
    }

    final elapsed = DateTime.now().difference(_recordingStartTime!);
    final remaining = maxDuration - elapsed;
    if (remaining == Duration.zero || remaining.isNegative) {
      stopRecording();
    } else {
      state = state.copyWith(remainingDuration: remaining);
    }
  }

  void updateReviewPosition(Duration currentPosition) {
    if (state.status != RecorderStatus.reviewing ||
        _actualRecordingDuration == null) {
      return;
    }
    final remaining = _actualRecordingDuration! - currentPosition;

    if (remaining == Duration.zero || remaining.isNegative) {
      state = state.copyWith(remainingDuration: _actualRecordingDuration!);
    } else {
      state = state.copyWith(remainingDuration: remaining);
    }
  }

  void resetReviewPosition() {
    if (state.status == RecorderStatus.reviewing &&
        _actualRecordingDuration != null) {
      state = state.copyWith(remainingDuration: _actualRecordingDuration!);
    }
  }

  Future<void> _deleteRecordingFile() async {
    try {
      final path = state.recordingPath;
      if (path == null) return;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting recording file: $e');
    }
  }

  Future<void> _resetToIdle() async {
    state = const AudioRecorderState(
      status: RecorderStatus.idle,
      remainingDuration: Duration.zero,
      recordingPath: null,
    );
  }

  void dispose() {
    _recorder.dispose();
  }
}

class AudioRecorderState {
  final RecorderStatus status;
  final Duration remainingDuration;
  final String? recordingPath;

  const AudioRecorderState({
    this.status = RecorderStatus.idle,
    this.remainingDuration = Duration.zero,
    this.recordingPath,
  });

  AudioRecorderState copyWith({
    RecorderStatus? status,
    Duration? remainingDuration,
    String? recordingPath,
    bool clearPath = false,
  }) {
    return AudioRecorderState(
      status: status ?? this.status,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      recordingPath: clearPath ? null : (recordingPath ?? this.recordingPath),
    );
  }
}
