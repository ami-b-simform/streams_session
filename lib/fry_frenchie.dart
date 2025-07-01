import 'dart:async';

import 'package:flutter/material.dart';

class FriesStreamHomePage extends StatefulWidget {
  const FriesStreamHomePage({super.key});

  @override
  State<FriesStreamHomePage> createState() => _FriesStreamHomePageState();
}

class _FriesStreamHomePageState extends State<FriesStreamHomePage> {
  // Broadcast stream allows multiple listeners
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  final List<String> _burgerKingStock = [];
  final List<String> _mcDStock = [];

  StreamSubscription<String>? _burgerKingSubscription;
  StreamSubscription<String>? _mcDSubscription;

  bool _mcDOpen = true;

  @override
  void initState() {
    super.initState();

    // Register listeners
    _startListening(_burgerKingStock, isMcD: false);
    _startListening(_mcDStock, isMcD: true);

    // Produce fries stream with transformations
    Stream<String>.periodic(
          const Duration(seconds: 2),
          (count) => "Fries batch #${count + 1}",
        )
        // Step 1: Filter only even batches
        .where((batch) {
          final batchNum = int.parse(batch.split('#').last);
          return batchNum % 2 == 0;
        })
        // Step 2: Add async freshness tag
        .asyncMap((batch) async {
          await Future.delayed(const Duration(milliseconds: 300));
          return "$batch - Fresh & Hot!";
        })
        // Step 3: Prevent duplicates
        .distinct()
        // Step 4: Timeout handling
        .timeout(
          const Duration(seconds: 1),
          onTimeout: (sink) => sink.add("Fries batch delayed... skipping"),
        )
        // Step 5: Expand into smaller fry pieces
        .asyncExpand((batch) async* {
          for (int i = 1; i <= 3; i++) {
            await Future.delayed(const Duration(milliseconds: 200));
            yield "$batch - Piece #$i";
          }
        })
        // Step 6: Custom transformation - make it SHOUT
        .transform(
          StreamTransformer<String, String>.fromHandlers(
            handleData: (data, sink) => sink.add(data.toUpperCase()),
          ),
        )
        // Final output to main controller
        .listen((data) {
          if (_controller.isClosed) return;
          _controller.add(data);
        });
  }

  /// Attach listener to stock list
  void _startListening(List<String> stockList, {required bool isMcD}) {
    final subscription = _controller.stream.listen(
      (data) => setState(() => stockList.add(data)),
      onError: (error) => setState(() => stockList.add("Error: $error")),
      onDone: () => setState(() => stockList.add("Stream completed!")),
    );

    if (isMcD) {
      _mcDSubscription = subscription;
    } else {
      _burgerKingSubscription = subscription;
    }
  }

  /// Toggle McD's subscription (simulate weekend closure)
  void _toggleMcD() {
    setState(() {
      _mcDOpen = !_mcDOpen;
      if (_mcDOpen) {
        _startListening(_mcDStock, isMcD: true);
      } else {
        _mcDSubscription?.cancel();
        _mcDSubscription = null;
      }
    });
  }

  /// UI Box for each listener
  Widget _buildListenerBox(String title, List<String> messages, bool isOpen) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: isOpen ? Colors.green : Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      height: 300,
      width: 170,
      child: Column(
        children: [
          Text(
            "$title (${isOpen ? 'Open' : 'Closed'})",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isOpen ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, index) => Text(messages[index]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fries Stream Demo")),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            "Fry Frenchie 🍟",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildListenerBox("Burger King", _burgerKingStock, true),
                _buildListenerBox("McD", _mcDStock, _mcDOpen),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _toggleMcD,
              child: Text(
                _mcDOpen
                    ? "Close McD (Simulate Closed Day)"
                    : "Open McD (Simulate Open Day)",
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _burgerKingSubscription?.cancel();
    _mcDSubscription?.cancel();
    _controller.close();
    super.dispose();
  }
}
