import 'dart:async';

import 'package:flutter/material.dart';

class StreamReListenDemo extends StatefulWidget {
  const StreamReListenDemo({super.key});

  @override
  State<StreamReListenDemo> createState() => _StreamReListenDemoState();
}

class _StreamReListenDemoState extends State<StreamReListenDemo> {
  late StreamController<String> _controller;
  late Stream<String> _stream;

  String? _streamData;
  String? _errorMessage;
  bool _showStreamBuilder = true;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _controller = StreamController<String>();
    _stream = _controller.stream;

    // Emit data with some delay to simulate async data
    Future.delayed(const Duration(seconds: 1), () {
      if (!_controller.isClosed) {
        _controller.add("🍔 Order #1: McAloo Tikki ready!");
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!_controller.isClosed) {
        _controller.add("🥤 Order #2: Coke delivered!");
      }
    });
  }

  void _tryRebuildWithSameStream() {
    // This simulates removing and re-adding the StreamBuilder with the same stream,
    // which will cause an error due to single-subscription stream reuse.
    setState(() {
      _errorMessage = null;
      _streamData = null;
      _showStreamBuilder = false;
    });

    // Re-add the StreamBuilder shortly after (to trigger the re-listen)
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        setState(() {
          _showStreamBuilder = true;
        });
      } catch (e) {
        setState(() {
          _errorMessage = "❌ Error on rebuild: $e";
        });
      }
    });
  }

  void _resetWithNewStream() {
    // Close old controller, create new stream & reset UI
    _controller.close();
    setState(() {
      _errorMessage = null;
      _streamData = null;
      _showStreamBuilder = true;
    });
    _initializeStream();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Rebuild Same Stream"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange.shade100,
          ),

          onPressed: _tryRebuildWithSameStream,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: const Text("Reset with New Stream"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange.shade100,
          ),

          onPressed: _resetWithNewStream,
        ),
      ],
    );
  }

  Widget _buildStreamOutput() {
    if (!_showStreamBuilder) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text("StreamBuilder hidden")),
      );
    }

    return StreamBuilder<String>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            "❌ StreamBuilder error: ${snapshot.error}",
            style: const TextStyle(color: Colors.red),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("⏳ Waiting for orders...");
        }
        if (snapshot.hasData) {
          _streamData = snapshot.data;
          return Text(
            "✅ ${snapshot.data}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          );
        }
        return const Text("🍽️ No more orders.");
      },
    );
  }

  Widget _buildErrorDisplay() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Single-Subscription Stream Demo"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildControlButtons(),
            const SizedBox(height: 30),
            const Text(
              "🎯 StreamBuilder Output:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 6,
              color: Colors.orange.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Center(child: _buildStreamOutput()),
              ),
            ),
            _buildErrorDisplay(),
            const Spacer(),
            const Text(
              "💡 Tip: Single-subscription streams can only be listened once.\nRe-using the same stream causes errors.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
