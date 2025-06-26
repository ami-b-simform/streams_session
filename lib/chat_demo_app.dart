import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDemoApp extends StatefulWidget {
  const ChatDemoApp({super.key});

  @override
  State<ChatDemoApp> createState() => _ChatDemoAppState();
}

class _ChatDemoAppState extends State<ChatDemoApp> {
  final List<Map<String, dynamic>> _allMessages = [];
  final StreamController<List<Map<String, dynamic>>> _chatController =
      StreamController.broadcast();
  final StreamController<bool> _typingController = StreamController();
  final TextEditingController _textController = TextEditingController();

  late StreamSubscription _botSubscription;

  bool isBotPaused = false;

  @override
  void initState() {
    super.initState();

    final initialMessages = [
      {
        'text': 'Welcome! This is an initial message',
        'isMe': false,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 1)),
      },
    ];
    _allMessages.addAll(initialMessages);
    _chatController.add(List.from(_allMessages));

    _botSubscription = Stream.periodic(const Duration(seconds: 8), (count) {
      if (count == 3) {
        // Simulate an error after 3 messages
        throw Exception('Simulated bot error');
      }
      return {
        'text': 'Bot reply #${count + 1}',
        'isMe': false,
        'timestamp': DateTime.now(),
      };
    }).asBroadcastStream().listen(
      (botMessage) {
        //Manually add a bot message to the chat
        _allMessages.add(botMessage);
        _chatController.add(List.from(_allMessages));
      },
      onError: (error) {
        debugPrint('Error in bot subscription: $error');
      },
      onDone: () {
        debugPrint('Bot subscription completed');
      },
      cancelOnError: false,
    );
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    _allMessages.add({
      'text': _textController.text.trim(),
      'isMe': true,
      'timestamp': DateTime.now(),
    });
    _chatController.add(List.from(_allMessages));
    _textController.clear();
    _typingController.add(false);
  }

  void _onTyping(String value) {
    if (value == 'error') {
      _typingController.addError('Simulated typing error');
    } else {
      _typingController.add(value.trim().isNotEmpty);
    }
  }

  // Simulated server stream using async*
  Stream<List<Map<String, dynamic>>> simulatedServerStream() async* {
    List<Map<String, dynamic>> messages = List.from(_allMessages);
    for (int i = 0; i <= 5; i++) {
      await Future.delayed(const Duration(seconds: 4));
      messages.add({
        'text': 'Server message #$i',
        'isMe': false,
        'timestamp': DateTime.now(),
      });
      if (i == 3) {
        throw Exception('Simulated error at message #$i');
      }
      yield List.from(messages);
    }
  }

  String _formatTime(DateTime time) => DateFormat('h:mm a').format(time);

  @override
  Widget build(BuildContext context) {
    final simulatedStream = simulatedServerStream();

    _typingController.onListen = () {
      debugPrint('Typing stream started');
    };
    _typingController.onCancel = () {
      debugPrint('Typing stream cancelled');
    };

    simulatedStream.listen(
      (messages) {
        debugPrint('Received from simulated stream: $messages');
      },
      onError: (error) {
        debugPrint('Error in simulated stream: $error');
      },
      onDone: () {
        debugPrint('Simulated stream completed');
      },
    );

    _chatController.stream.listen(
      (messages) {
        debugPrint('Chat stream updated: $messages');
      },
      onError: (error) {
        debugPrint('Error in chat stream: $error');
      },
      onDone: () {
        debugPrint('Chat stream completed');
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Live Chat Demo")),
      body: SafeArea(
        child: Column(
          children: [
            // Typing Status
            StreamBuilder<bool>(
              stream: _typingController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                bool isTyping = snapshot.data ?? false;
                return isTyping
                    ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'User is typing...',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    )
                    : const SizedBox.shrink();
              },
            ),

            // Chat Messages
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _chatController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data ?? _allMessages;

                  if (messages.isEmpty) {
                    return const Center(child: Text("No messages yet"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final isMe = messages[index]['isMe'] as bool;
                      final text = messages[index]['text'] as String;
                      final timestamp =
                          messages[index]['timestamp'] as DateTime;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 250),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.teal : Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isMe ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (isBotPaused) {
                        _botSubscription.resume();
                        setState(() {
                          isBotPaused = false;
                        });
                        debugPrint("Bot subscription resumed");
                      } else {
                        _botSubscription.pause();
                        setState(() {
                          isBotPaused = true;
                        });
                        debugPrint("Bot subscription paused");
                      }
                    },
                    child: Text(isBotPaused ? "Resume Bot" : "Pause Bot"),
                  ),
                ),
              ],
            ),

            // Input Field
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: _onTyping,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatController.close();
    _typingController.close();
    _botSubscription.cancel();
    _textController.dispose();
    super.dispose();
  }
}
