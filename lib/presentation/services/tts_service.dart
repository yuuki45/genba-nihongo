import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech サービス
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String? _lastError;

  /// 最後のエラーメッセージを取得
  String? get lastError => _lastError;

  /// 初期化
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // 日本語に設定
      await _flutterTts.setLanguage('ja-JP');

      // 音声速度を設定（0.0 - 1.0）
      await _flutterTts.setSpeechRate(0.5);

      // ピッチを設定（0.5 - 2.0）
      await _flutterTts.setPitch(1.0);

      // ボリュームを設定（0.0 - 1.0）
      await _flutterTts.setVolume(1.0);

      _isInitialized = true;
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      _lastError = 'TTS初期化エラー: $e';
      debugPrint('TTS初期化エラー: $e');
      debugPrint('スタックトレース: $stackTrace');
      return false;
    }
  }

  /// 読み上げ終了時のコールバックを設定
  ///
  /// 正常完了と停止（キャンセル）の両方で呼ばれる。
  /// 画面側で再生中インジケーターの解除に使う。nullで解除。
  void setOnComplete(VoidCallback? callback) {
    _flutterTts.setCompletionHandler(callback ?? () {});
    _flutterTts.setCancelHandler(callback ?? () {});
  }

  /// テキストを読み上げる
  Future<bool> speak(String text) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      await _flutterTts.speak(text);
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      _lastError = 'TTS読み上げエラー: $e';
      debugPrint('TTS読み上げエラー: $e');
      debugPrint('スタックトレース: $stackTrace');
      return false;
    }
  }

  /// 読み上げを停止
  Future<bool> stop() async {
    try {
      await _flutterTts.stop();
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      _lastError = 'TTS停止エラー: $e';
      debugPrint('TTS停止エラー: $e');
      debugPrint('スタックトレース: $stackTrace');
      return false;
    }
  }

  /// 一時停止
  Future<bool> pause() async {
    try {
      await _flutterTts.pause();
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      _lastError = 'TTS一時停止エラー: $e';
      debugPrint('TTS一時停止エラー: $e');
      debugPrint('スタックトレース: $stackTrace');
      return false;
    }
  }

  /// 読み上げ中かどうか
  Future<bool> get isSpeaking async {
    try {
      final status = await _flutterTts.awaitSpeakCompletion(true);
      return status == 1;
    } catch (e) {
      return false;
    }
  }

  /// リソースを解放
  void dispose() {
    _flutterTts.stop();
  }
}
