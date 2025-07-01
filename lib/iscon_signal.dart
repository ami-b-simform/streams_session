import 'dart:async';

import 'package:flutter/material.dart';

enum TrafficSignal { red, green }

class TrafficSignalHomePage extends StatefulWidget {
  const TrafficSignalHomePage({super.key});

  @override
  State<TrafficSignalHomePage> createState() => _TrafficSignalHomePageState();
}

class _TrafficSignalHomePageState extends State<TrafficSignalHomePage> {
  final StreamController<String> _vehicleStream = StreamController.broadcast();
  final Map<String, StreamSubscription<String>> _roadSubscriptions = {};
  final Map<String, String> _roadStatus = {
    "🛣️ Road A": "⏳ Waiting...",
    "🛣️ Road B": "⏳ Waiting...",
    "🛣️ Road C": "⏳ Waiting...",
  };

  TrafficSignal _currentSignal = TrafficSignal.green;
  Timer? _vehicleTimer;
  bool _isStreamClosed = false;

  @override
  void initState() {
    super.initState();
    _startVehicleFlow();
    _addRoad("🛣️ Road A");
    _addRoad("🛣️ Road B");
    _addRoad("🛣️ Road C");
  }

  void _startVehicleFlow() {
    _vehicleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_isStreamClosed) {
        // Safeguard to prevent adding to a closed stream
        final vehicle = "🚗 Vehicle @${DateTime.now().second}";
        _vehicleStream.add(vehicle);
      }
    });
  }

  void _addRoad(String roadName) {
    final subscription = _vehicleStream.stream.listen((vehicle) {
      setState(() {
        _roadStatus[roadName] = "$vehicle received on $roadName";
      });
    });

    _roadSubscriptions[roadName] = subscription;
  }

  void _setSignal(TrafficSignal signal) {
    setState(() {
      _currentSignal = signal;

      if (signal == TrafficSignal.red) {
        _pauseAllSubscriptions();
        _roadStatus.updateAll((key, _) => "⛔ Paused at Red");
      } else if (signal == TrafficSignal.green) {
        _resumeAllSubscriptions();
        _roadStatus.updateAll((key, _) => "🚦 Green - Ready to receive");
      }
    });
  }

  void _pauseAllSubscriptions() {
    for (var sub in _roadSubscriptions.values) {
      sub.pause();
    }
  }

  void _resumeAllSubscriptions() {
    for (var sub in _roadSubscriptions.values) {
      sub.resume();
    }
  }

  void _cancelAll() {
    _vehicleTimer?.cancel(); // Cancel the timer to stop periodic events
    _vehicleTimer = null;

    for (var sub in _roadSubscriptions.values) {
      sub.cancel();
    }

    _roadSubscriptions.clear();
    _isStreamClosed = true; // Mark the stream as closed
    _vehicleStream.close(); // Close the stream
  }

  @override
  void dispose() {
    _cancelAll();
    super.dispose();
  }

  String get signalText {
    switch (_currentSignal) {
      case TrafficSignal.red:
        return "🔴 Red";
      case TrafficSignal.green:
        return "🟢 Green";
    }
  }

  Widget _buildSignalButton(String emoji, TrafficSignal signal, Color color) {
    return ElevatedButton(
      onPressed: () => _setSignal(signal),
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(emoji),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Iscon Cross Road Traffic Signal 🚦"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Current Signal Display
            Text(
              "Current Signal: $signalText",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Signal Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSignalButton(
                  "🔴 RED",
                  TrafficSignal.red,
                  Colors.red.shade100,
                ),
                _buildSignalButton(
                  "🟢 GREEN",
                  TrafficSignal.green,
                  Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Each road’s UI block
            Expanded(
              child: ListView(
                children:
                    _roadStatus.entries.map((entry) {
                      return Card(
                        elevation: 4,
                        child: ListTile(
                          leading: const Icon(Icons.traffic),
                          title: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
