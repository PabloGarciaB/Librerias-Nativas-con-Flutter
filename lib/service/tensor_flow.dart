

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TensorFlow {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/mobilenet_v1_1.0_224.tflite');
      debugPrint("Model loaded successfully");
      if(_interpreter != null) {
        var inputShape = _interpreter!.getInputTensor(0).shape;
        var outputShape = _interpreter!.getOutputTensor(0).shape;
        debugPrint("Input shape: $inputShape");
        debugPrint("Output shape: $outputShape");
      }
    } catch (e) {
      debugPrint("Error loading model: $e");
    }
  }

  Future<List<double>> runModel(File image) async {
    if(_interpreter == null) {
      debugPrint("Model is not loaded");
      return [];
    }

    var input = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) => List.generate(3, (c) => 0.0))));

    img.Image imageInput = img.decodeImage(await image.readAsBytes())!;
    img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);

    for(var y = 0; y < resizedImage.height; y++) {
      for(var x = 0; x < resizedImage.width; x++) {
        var pixel = resizedImage.getPixel(x, y);

        var r = pixel.r;
        var g = pixel.g;
        var b = pixel.b;

        input[0][y][x][0] = r / 255.0;
        input[0][y][x][1] = g / 255.0;
        input[0][y][x][2] = b / 255.0;
      }
    }

    //Models are based in matrixs, call the result (1), 1001 (number of classes), 
    //meaning a posibility for each class for whatever we have as input
    var output = List.filled(1 * 1001, 0.0).reshape([1,1001]);

    try {
        _interpreter!.run(input, output);
        debugPrint("Result: $output");
        return output[0];
      } catch (e) {
        debugPrint("Error running model: $e");
        return [];
      }
  }

  void close (){
    _interpreter?.close();
  }

}