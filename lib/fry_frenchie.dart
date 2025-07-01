import 'dart:async';

import 'package:flutter/material.dart';

class FriesStreamHomePage extends StatefulWidget {
  const FriesStreamHomePage({super.key});

  @override
  State<FriesStreamHomePage> createState() => _FriesStreamHomePageState();
}

class _FriesStreamHomePageState extends State<FriesStreamHomePage> {
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
    _startListening(_burgerKingStock, isMcD: false);
    _startListening(_mcDStock, isMcD: true);

    Stream<String>.periodic(
      const Duration(seconds: 2),
      (count) => "Fries batch #${count + 1}",
    ).listen(_controller.add);
  }

  void _startListening(List<String> stockList, {required bool isMcD}) {
    final subscription = _controller.stream.listen(
      (fries) => setState(() => stockList.add(fries)),
      onDone: () => setState(() => stockList.add("Stream completed!")),
      onError: (error) => setState(() => stockList.add("Error: $error")),
    );

    if (isMcD) {
      _mcDSubscription = subscription;
    } else {
      _burgerKingSubscription = subscription;
    }
  }

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
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          "Fry Frenchie 🍟",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 24),
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
