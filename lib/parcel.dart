import 'dart:async';

import 'package:flutter/material.dart';

class ParcelSortingScreen extends StatefulWidget {
  const ParcelSortingScreen({super.key});

  @override
  State<ParcelSortingScreen> createState() => _ParcelSortingScreenState();
}

class _ParcelSortingScreenState extends State<ParcelSortingScreen> {
  // StreamController to manage the stream of parcels
  final _controller = StreamController<String>();

  // List to store processed parcels
  final List<String> _processed = [];

  // Status message to display current state
  String _status = "📦 Waiting for parcels...";

  // Function to send a parcel into the stream
  void _sendParcel(String parcel) {
    _controller.sink.add(parcel);
  }

  @override
  void initState() {
    super.initState();

    // Setting up the stream pipeline
    _controller.stream
        // Remove duplicate parcels
        .distinct()
        // Simulate scanning delay
        .asyncMap((parcel) async {
          setState(() => _status = "🔍 Scanning: $parcel");
          await Future.delayed(Duration(seconds: 2));

          // Throw an error if the parcel is damaged
          if (parcel == "💣 Crushed Parcel") throw Exception("Parcel damaged!");

          return parcel;
        })
        // Timeout if no parcel is received within 6 seconds
        .timeout(
          Duration(seconds: 6),
          onTimeout: (sink) => sink.add("⏰ Timeout: No Parcel received!"),
        )
        // Expand gift box into multiple items
        .asyncExpand((parcel) async* {
          if (parcel == "🎁 Gift Box") {
            yield* Stream.fromIterable([
              "🍫 Chocolate",
              "🎉 Party Hat",
              "🧸 Teddy Bear",
            ]);
          } else {
            yield parcel;
          }
        })
        // Transform the stream to decorate items based on their type
        .transform(
          StreamTransformer.fromHandlers(
            handleData: (input, sink) {
              // Assign appropriate emoji tags based on item type
              if (input.startsWith("⏰") || input.startsWith("🔥")) {
                sink.add(input);
                return;
              }
              String tag =
                  input.contains("Pizza")
                      ? "🍕"
                      : input.contains("Shoes")
                      ? "👟"
                      : input.contains("Phone")
                      ? "📱"
                      : input.contains("Chocolate")
                      ? "🍫"
                      : input.contains("Teddy")
                      ? "🧸"
                      : input.contains("Hat")
                      ? "🎉"
                      : "📦";
              sink.add("$tag $input");
            },
            handleError: (error, stack, sink) {
              // Handle errors and add an error message to the stream
              sink.addError("🔥 Error: $error");
            },
          ),
        )
        // Listen to the stream and update the UI accordingly
        .listen(
          (event) {
            setState(() {
              _processed.insert(
                0,
                event.toString(),
              ); // Add processed item to the list
              _status = "✅ Processed: $event"; // Update status message
            });
          },
          onError: (error) {
            setState(() {
              _status = error.toString(); // Update status with error message
              _processed.insert(0, "🔥 Error: $error"); // Add error to the list
            });
          },
          onDone: () {
            setState(
              () => _status = "🎉 All parcels processed!",
            ); // Final status message
          },
        );
  }

  @override
  void dispose() {
    // Close the StreamController to release resources
    _controller.close();
    super.dispose();
  }

  // Helper function to create parcel buttons
  Widget _parcelButton(String label) =>
      ElevatedButton(onPressed: () => _sendParcel(label), child: Text(label));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Parcel Sorting Machine 📦")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the current status
            Text(
              _status,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            // Buttons to simulate sending parcels
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _parcelButton("Pizza"),
                _parcelButton("Phone"),
                _parcelButton("Shoes"),
                _parcelButton("🎁 Gift Box"),
                _parcelButton("💣 Crushed Parcel"),
                _parcelButton("Pizza"),
              ],
            ),
            SizedBox(height: 20),
            // Display the list of processed parcels
            Text("📋 Processed Parcels:", style: TextStyle(fontSize: 16)),
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _processed.length,
                itemBuilder:
                    (_, index) => ListTile(
                      title: Text(_processed[index]),
                      leading: Icon(Icons.inventory_2),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
