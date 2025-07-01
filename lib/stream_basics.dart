import 'dart:async';

import 'package:flutter/material.dart';

class StreamBasics extends StatefulWidget {
  const StreamBasics({super.key});

  @override
  State<StreamBasics> createState() => _StreamBasicsState();
}

class _StreamBasicsState extends State<StreamBasics> {
  final StreamController<int> stream =
      StreamController<int>.broadcast(); // Broadcast stream controller

  @override
  void initState() {
    super.initState();

    // Send events with delay to simulate real-time stream
    Future.delayed(const Duration(seconds: 1), () => stream.add(1));
    Future.delayed(const Duration(seconds: 2), () => stream.add(2));

    // Listener 1
    stream.stream.listen(
      (data) => debugPrint('Listener1: Data $data'),
      onError: (error) => debugPrint('Listener1: Error $error'),
      onDone: () => debugPrint('Listener1: Stream closed'),
      cancelOnError: true, // Cancel the subscription if an error occurs
    );

    // Create a broadcast stream to support multiple listeners
    final broadcastStream = stream.stream.asBroadcastStream();

    // Send an error event after 3 seconds
    Future.delayed(
      const Duration(seconds: 3),
      () => stream.addError("🔥 Error occurred!"),
    );

    // Listener 2 using broadcastStream so that multiple listeners can subscribe
    broadcastStream.listen(
      (data) => debugPrint('Listener2: Data $data'),
      onError: (error) => debugPrint('Listener2: Error $error'),
      onDone: () => debugPrint('Listener2: Stream closed'),
    );

    // Add more data after 4 seconds
    Future.delayed(const Duration(seconds: 4), () => stream.add(3));
  }

  @override
  void dispose() {
    stream.close(); // Always close the stream to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Streams Basic Demo")),
      body: Center(
        child: StreamBuilder<int>(
          stream: stream.stream, // Connected to the same stream
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Initial state
            } else if (snapshot.hasError) {
              return Text(
                'StreamBuilder Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 20),
              ); // Error state
            } else if (snapshot.hasData) {
              return Text(
                'StreamBuilder: ${snapshot.data}',
                style: const TextStyle(fontSize: 20),
              ); // Data received
            } else {
              return const Text(
                'Waiting for data...',
                style: TextStyle(fontSize: 20),
              ); // Fallback
            }
          },
        ),
      ),
    );
  }
}
