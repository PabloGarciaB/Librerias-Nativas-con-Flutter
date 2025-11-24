import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  String _recognizedText = 'Say something...';


  Future<void> startListening() async {
    bool available = await _speechToText.initialize();
    if(available) {
      _isListening = true;
      _speechToText.listen(onResult: _onSpeechResult);
    } else {
      _recognizedText = 'Speech recognition not available';
    }    
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    print("result: ${result.recognizedWords}");
    _recognizedText = result.recognizedWords;
  }

  void stopListening() {
    _speechToText.stop();
    _isListening = false;
  }

  String get recognizedText => _recognizedText;
  bool get isListening => _isListening;

}