import 'dart:async';

import 'package:flutter/material.dart';

class FriesStreamApp extends StatelessWidget {
  const FriesStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fries Stream Demo',
      home: const FriesStreamHomePage(),
    );
  }
}

class FriesStreamHomePage extends StatefulWidget {
  const FriesStreamHomePage({super.key});

  @override
  State<FriesStreamHomePage> createState() => _FriesStreamHomePageState();
}

class _FriesStreamHomePageState extends State<FriesStreamHomePage> {
  final StreamController<String> controller =
      StreamController<String>.broadcast();

  final List<String> burgerKingMessages = [];
  final List<String> mcDMessages = [];

  StreamSubscription<String>? mcDSubscription;
  bool mcDOpen = true;
  int friesBatchNumber = 0;
  Timer? friesTimer;

  @override
  void initState() {
    super.initState();

    // Burger King listens continuously
    controller.stream.listen((fries) {
      setState(() {
        burgerKingMessages.add(fries);
      });
    });

    // McD starts listening immediately
    _startMcDListening();

    // Generate fries batches every 2 seconds
    friesTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      friesBatchNumber++;
      String friesBatch = "Fries batch #$friesBatchNumber";
      controller.add(friesBatch);
    });
  }

  void _startMcDListening() {
    mcDSubscription = controller.stream.listen((fries) {
      setState(() {
        mcDMessages.add(fries);
      });
    });
  }

  void _resumeMcDListening() {
    mcDSubscription?.resume();
  }

  void _stopMcDListening() {
    mcDSubscription?.cancel();
    mcDSubscription = null;
  }

  void _pauseMcDListening() {
    mcDSubscription?.pause();
  }

  void _toggleMcD() {
    setState(() {
      mcDOpen = !mcDOpen;
      if (mcDOpen) {
        // _startMcDListening();
        _resumeMcDListening();
      } else {
        // _stopMcDListening();
        _pauseMcDListening();
      }
    });
  }

  @override
  void dispose() {
    friesTimer?.cancel();
    mcDSubscription?.cancel();
    controller.close();
    super.dispose();
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
      width: 160,
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
      appBar: AppBar(title: const Text("Fries Stream - Burger King & McD")),
      body: SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            Flexible(
              child: Row(
                children: [
                  _buildListenerBox("Burger King", burgerKingMessages, true),
                  _buildListenerBox("McD", mcDMessages, mcDOpen),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _toggleMcD,
                child: Text(
                  mcDOpen
                      ? "Close McD (Simulate Closed Day)"
                      : "Open McD (Simulate Open Day)",
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Burger King listens continuously and receives all fries batches.\n"
                "McD can be toggled open/closed. When reopened, it receives new fries batches from that moment.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
