// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:demoprojecttwo/api_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:http/http.dart' as http;

class GirlieChatScreen extends StatefulWidget {
  const GirlieChatScreen({super.key});

  @override
  State<GirlieChatScreen> createState() => _GirlieChatScreenState();
}

class _GirlieChatScreenState extends State<GirlieChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> messages = [];

  bool isBotTyping = false; // stops user typing
  bool isLoading = false;

  String typingText = "";

  // Auto scroll
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Typing effect
  Future<void> startTypingEffect(String fullText) async {
    setState(() {
      // LOCK INPUT
      isBotTyping = true;
    });

    typingText = "";
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 18));
      setState(() {
        typingText += fullText[i];
      });
      scrollToBottom();
    }

    setState(() {
      messages.add({"sender": "bot", "text": typingText});
      typingText = "";
      isBotTyping = false; // UNLOCK INPUT
    });

    scrollToBottom();
  }

  // Send user message → Gemini
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isBotTyping) return;

    setState(() {
      messages.add({"sender": "me", "text": text});
      isLoading = true;
      isBotTyping = true; // prevent typing
    });

    scrollToBottom();
    _controller.clear();

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${ApiKeys.geminiApiKey}",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": text},
              ],
            },
          ],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["candidates"] != null &&
          data["candidates"][0]["content"]["parts"][0]["text"] != null) {
        String botReply = data["candidates"][0]["content"]["parts"][0]["text"];
        await startTypingEffect(botReply);
      } else {
        await startTypingEffect("Aww babe… I couldn’t understand that 😔💗");
      }
    } catch (e) {
      await startTypingEffect(
        "Oops babe… something went wrong 🥺💔 Please check your Internet or API key.",
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      messages.add({
        "sender": "bot",
        "text":
            "Hi love 💞 I’m your **Girlie AI**, here to listen to whatever your heart is carrying — good or bad.\n\nYou're safe with me, sweetheart 💗\n\n**Tell me… how are you feeling right now? 🫶**",
      });

      scrollToBottom();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade400,
        title: const Text(
          "Girlie ChatBot 💖",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              children: [
                ...messages.map((msg) {
                  bool isMe = msg["sender"] == "me";

                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.pink.shade300 : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: MarkdownBody(
                        data: msg["text"]!,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                          strong: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          em: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Typing animation bubble
                if (typingText.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        typingText,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Girlie is thinking… 💞",
                style: TextStyle(color: Colors.pink),
              ),
            ),

          // Input bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !isBotTyping,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: isBotTyping
                          ? "Girlie is typing… 💗"
                          : "Tell me anything sweetie… 💗",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: isBotTyping
                      ? null
                      : () {
                          sendMessage(_controller.text);
                        },
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: isBotTyping
                        ? Colors.pink.shade200
                        : Colors.pink.shade400,
                    child: Icon(
                      Icons.send,
                      color: Colors.white.withValues(
                        alpha: isBotTyping ? 0.5 : 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
