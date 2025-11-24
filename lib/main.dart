import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_tflow/speech_service.dart';
import 'package:image_picker/image_picker.dart';

import 'service/tensor_flow.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final tfService = TensorFlow();
  final speechService = SpeechService();
  await tfService.loadModel();
  runApp( MainApp(tfService: tfService, speechService: speechService));
}

class MainApp extends StatelessWidget {
  final TensorFlow tfService;
  final SpeechService speechService;
  const MainApp({super.key, required this.tfService, required this.speechService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ModelScreen(
        tfService: tfService,
        speechService: speechService,
      ),
    );
  }
}

class ModelScreen extends StatefulWidget {
  final TensorFlow tfService;
  final SpeechService speechService;
  const ModelScreen({super.key, required this.tfService, required this.speechService});

  @override
  ModelScreenState createState() => ModelScreenState();
}

class ModelScreenState extends State<ModelScreen> {
  String _output = "Tap to run model";
  File? _image;


  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }
  //Y is height, x is width, c is color channel (RGB)
  void _runModel() async {

    if(_image == null) {
      setState(() {
        _output = "No image selected";
      });
    }


    try {
      var result = await widget.tfService.runModel(_image!);
      setState(() {
        _output = "Model output: $result";
      });

    } catch (e) {
      debugPrint("Error preparing input: $e");
      setState(() {
        _output = "Error running model";
      });
    }
  }

  void _toggleListening() {
    if(widget.speechService.isListening) {
      widget.speechService.stopListening();
    } else {
      widget.speechService.startListening();
    }
  }
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TensorFlow Lite Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _image == null ? const Text('No image selected') : Image.file(_image!, height: 200, width: 200),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _runModel,
              child: const Text('Run Model'),
            ),
            Text("Listening: ${widget.speechService.recognizedText}"),
            ElevatedButton(
              onPressed: _toggleListening,
              child: Text(widget.speechService.isListening ? 'Stop Listening' : 'Start Listening'),
            ),
            Text(
              _output, 
              textAlign: TextAlign.center,
            ),            
          ],
        ),
      ),
    );
  }
}
