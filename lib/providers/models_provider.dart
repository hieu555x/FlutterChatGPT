import 'package:chatgpt_app/models/models_model.dart';
import 'package:chatgpt_app/services/api_service.dart';
import 'package:flutter/material.dart';

class ModelsProvider with ChangeNotifier {
  String currentModels = "text-davinci-003";

  String get getCurrentModels {
    return currentModels;
  }

  void setCurrentModel(String newModel) {
    currentModels = newModel;
    notifyListeners();
  }

  List<ModelsModel> modelsList = [];

  List<ModelsModel> get getModelsList {
    return modelsList;
  }

  Future<List<ModelsModel>> getAllModels() async {
    modelsList = await ApiService.getModels();
    return modelsList;
  }
}
