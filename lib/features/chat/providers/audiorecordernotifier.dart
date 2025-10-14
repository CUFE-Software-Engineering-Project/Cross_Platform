import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lite_x/core/classes/AudioRecorderUtil.dart';

part 'audiorecordernotifier.g.dart';

@riverpod
class AudioRecorderNotifier extends _$AudioRecorderNotifier {
  final _recorder = AudioRecorderUtil();
  DateTime? _startTime;

  @override
  AudioRecorderState build() => AudioRecorderState();

  Future<bool> startRecording() async {
    final success = await _recorder.startRecording();
    if (success) {
      _startTime = DateTime.now();
      state = state.copyWith(isRecording: true);
    }
    return success;
  }

  Future<String?> stopRecording() async {
    final path = await _recorder.stopRecording();
    state = state.copyWith(
      isRecording: false,
      recordingDuration: Duration.zero,
      recordingPath: path,
    );
    _startTime = null;
    return path;
  }

  Future<void> cancelRecording() async {
    await _recorder.cancelRecording();
    state = state.copyWith(
      isRecording: false,
      recordingDuration: Duration.zero,
      recordingPath: null,
    );
    _startTime = null;
  }

  void updateDuration() {
    if (_startTime != null && state.isRecording) {
      final duration = DateTime.now().difference(_startTime!);
      state = state.copyWith(recordingDuration: duration);
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}

class AudioRecorderState {
  final bool isRecording;
  final Duration recordingDuration;
  final String? recordingPath;

  const AudioRecorderState({
    this.isRecording = false,
    this.recordingDuration = Duration.zero,
    this.recordingPath,
  });

  AudioRecorderState copyWith({
    bool? isRecording,
    Duration? recordingDuration,
    String? recordingPath,
  }) {
    return AudioRecorderState(
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      recordingPath: recordingPath ?? this.recordingPath,
    );
  }
}
