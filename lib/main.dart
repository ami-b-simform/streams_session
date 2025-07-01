import 'package:flutter/material.dart';
import 'package:streams_session_demo/parcel.dart';

import 'flight_adda.dart';
import 'fry_frenchie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Stream Examples'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.fastfood), text: 'Fries Stream'),
                Tab(icon: Icon(Icons.flight), text: 'Airport'),
                Tab(
                  icon: Icon(Icons.card_giftcard_outlined),
                  text: 'Parcel Sorting',
                ),
                // Tab(icon: Icon(Icons.traffic), text: 'Traffic Signal'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              const FriesStreamHomePage(),
              const DesiAddaHomePage(),
              const ParcelSortingScreen(),
              // const TrafficSignalHomePage(),
            ],
          ),
        ),
      ),
    );
  }
}
