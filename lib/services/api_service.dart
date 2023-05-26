import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatgpt_app/constants/api_consts.dart';
import 'package:chatgpt_app/models/models_model.dart';
import 'package:http/http.dart' as http;

import '../models/chat_model.dart';

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {
          "Authorization": "Bearer $API_KEY",
        },
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        print("json response error: ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      //print("jsonresponse : $jsonResponse");

      List temp = [];
      for (var value in jsonResponse['data']) {
        temp.add(value);
        // log("temp : ${value["id"]}");
      }

      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      log("error: $error");
      rethrow;
    }
  }

  //Send Messgae Function
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelID}) async {
    log("Model: $modelID");
    try {
      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {
          "Authorization": "Bearer $API_KEY",
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          {
            "model": modelID,
            "messages": [
              {"role": "user", "content": message}
            ]
          },
        ),
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        print("json response error: ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }

      List<ChatModel> chatModelsList = [];

      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices] text is: ${jsonResponse["choices"][0]["text"]}");
        chatModelsList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
              message: jsonResponse["choices"][index]["message"]["content"],
              chatIndex: 1),
        );
      }
      return chatModelsList;
    } catch (error) {
      log("error: $error");
      rethrow;
    }
  }
}
