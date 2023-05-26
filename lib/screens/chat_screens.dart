import 'dart:developer';

import 'package:chatgpt_app/constants/constants.dart';
import 'package:chatgpt_app/providers/chat_provider.dart';
import 'package:chatgpt_app/services/assets_manager.dart';
import 'package:chatgpt_app/services/services.dart';
import 'package:chatgpt_app/widget/chat_widget.dart';
import 'package:chatgpt_app/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../providers/models_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTying = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            AssetsManager.openAiLogo,
          ),
        ),
        title: const Text("ChatGPT"),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(
                context: context,
              );
            },
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.chatList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    message: chatProvider.chatList[index].message,
                    chatIndex: chatProvider.chatList[index].chatIndex,
                  );
                },
              ),
            ),
            if (_isTying) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 15,
            ),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        controller: textEditingController,
                        onSubmitted: (value) async {
                          // TODO send message
                          await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        decoration: const InputDecoration.collapsed(
                          hintText: "How can I help you",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        log(textEditingController.text);
                        await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider);
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTying) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You can't send multiple message at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type your message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String message = textEditingController.text;
      setState(() {
        _isTying = true;
        // chatList
        //     .add(ChatModel(message: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(message: message);
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswer(
          message: message, choosenModelID: modelsProvider.getCurrentModels);
      // chatList.addAll(
      //   await ApiService.sendMessage(
      //     message: textEditingController.text,
      //     modelID: modelsProvider.getCurrentModels,
      //   ),
      // );
      log("textEditingController: ${textEditingController.text}");
      setState(() {});
    } catch (error) {
      log("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            label: error.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      scrollListToEnd();
      setState(() {
        _isTying = false;
      });
    }
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }
}
