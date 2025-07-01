import 'dart:async';

import 'package:flutter/material.dart';

/// Home Page: Simulates airport flight handling using Streams
class DesiAddaHomePage extends StatefulWidget {
  const DesiAddaHomePage({super.key});
  @override
  State<DesiAddaHomePage> createState() => _DesiAddaHomePageState();
}

class _DesiAddaHomePageState extends State<DesiAddaHomePage> {
  // StreamController to manage flight streams
  final StreamController<String> _flightController =
      StreamController<String>.broadcast();

  // List to store announcements
  final List<String> _announcements = [];

  // Current flight being handled
  String _currentFlight = '🛫 Waiting for flights...';

  // Status of the ground crew
  String _groundStatus = "🧍‍♂️ Waiting for flight to handle...";

  // Sample flights list
  final List<String> _flights = [
    "Indigo 6E-7204 🛬",
    "Vistara UK-512 🛬",
    "SpiceJet SG-123 🛬",
    "Air India AI-101 🛬",
    "GoAir G8-987 🛬",
  ];

  @override
  void initState() {
    super.initState();
    // Initialize flight stream, announcer, and ground crew handling
    _startFlightStream();
    _setupAnnouncer();
    _handleFlightsSequentially();
  }

  /// STREAM PRODUCER: Simulates flights landing one by one
  Future<void> _startFlightStream() async {
    for (var flight in _flights) {
      // Simulate delay for each flight
      await Future.delayed(const Duration(seconds: 3));
      _flightController.add(flight);
      setState(() {
        _currentFlight = flight;
      });
    }

    // Close the stream after all flights are handled
    await Future.delayed(const Duration(seconds: 2));
    await _flightController.close();
  }

  /// .listen(): React immediately when a flight lands (Adda Announcer)
  void _setupAnnouncer() {
    _flightController.stream.listen(
      (flight) {
        setState(() {
          // Add announcement for each flight
          _announcements.insert(0, "📢 Adda Announcer: $flight aaya bhai!");
        });
      },
      onDone: () {
        setState(() {
          // Final announcement when all flights are handled
          _announcements.insert(0, "🎉 Sab flights aa gaye. Adda bandh!");
        });
      },
    );
  }

  /// await for: Handle flights one-by-one like ground crew
  Future<void> _handleFlightsSequentially() async {
    await for (var flight in _flightController.stream) {
      setState(() {
        // Update ground crew status for each flight
        _groundStatus = "🛠️ Servicing: $flight";
      });
      await Future.delayed(const Duration(seconds: 3)); // Simulate service time

      setState(() {
        // Mark flight as serviced
        _groundStatus = "✅ Done with: $flight";
      });
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Small pause before next
    }

    setState(() {
      // Final status when all flights are handled
      _groundStatus = "🎉 All flights handled! Ground crew done!";
    });
  }

  @override
  void dispose() {
    // Close the StreamController to release resources
    _flightController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Desi Adda Airport ✈️',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: 24),
            ),
            // 🖥️ DIGITAL FLIGHT BOARD (StreamBuilder)
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: StreamBuilder<String>(
                  stream: _flightController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display message while waiting for flights
                      return const Text(
                        "🛫 Waiting for flights...",
                        style: TextStyle(fontSize: 20),
                      );
                    } else if (snapshot.hasData) {
                      // Display the current flight landing
                      return Text(
                        "🖥️ Board: Now landing — ${snapshot.data}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      // Display message when all flights are handled
                      return const Text(
                        "✅ All flights handled. Shukriya!",
                        style: TextStyle(fontSize: 20),
                      );
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🧍‍♂️ GROUND CREW STATUS (await for UI)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.engineering, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _groundStatus,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📢 ANNOUNCEMENTS (listen UI)
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _announcements.length,
                itemBuilder: (context, index) {
                  // Display each announcement in a list
                  return ListTile(
                    leading: const Icon(
                      Icons.campaign,
                      color: Colors.deepOrange,
                    ),
                    title: Text(_announcements[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
