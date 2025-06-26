import 'package:flutter/material.dart';

import 'chat_demo_app.dart';

class StreamDemo extends StatelessWidget {
  const StreamDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // A stream generator function that emits integers from 0 to 9.
    // Each value is emitted after a delay of 1 second.
    Stream<int> counterStream() async* {
      for (int i = 0; i < 10; i++) {
        if (i == 5) {
          // This will close the stream with an error when i is 5.
          throw Exception('An error occurred at $i');
        }
        await Future.delayed(const Duration(seconds: 1));
        yield i;
      }
    }

    // final counterStreamInstance = counterStream();

    final broadCastStreamInstance = counterStream().asBroadcastStream();

    // counterStreamInstance().listen(
    // counterStreamInstance.listen(
    broadCastStreamInstance.listen(
      (data) {
        // This is where you can handle each emitted value.
        print('Received: $data');
      },
      onError: (error) {
        // Handle the error from the stream.
        print('Stream error: $error');
      },
      onDone: () {
        // This will be called when the stream is done.
        print('Stream completed');
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Counter Demo")),
      body: Center(
        child: StreamBuilder<int>(
          // stream: counterStream(),
          // stream: counterStreamInstance,
          stream: broadCastStreamInstance,

          builder: (context, snapshot) {
            final state = snapshot.connectionState;

            if (state == ConnectionState.waiting) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Starting stream...', style: TextStyle(fontSize: 16)),
                ],
              );
            }

            if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              );
            }

            if (state == ConnectionState.active && snapshot.hasData) {
              return Text(
                'Counter: ${snapshot.data}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              );
            }

            if (state == ConnectionState.done) {
              return Column(
                children: [
                  const Text(
                    'Done!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              );
            }

            return const Text(
              'No data yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const ChatDemoApp()));
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
