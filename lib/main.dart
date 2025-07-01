import 'package:flutter/material.dart';
import 'package:streams_session_demo/fry_frenchie.dart';
import 'package:streams_session_demo/stream_basics.dart';

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
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Stream Demos'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.sync), text: 'Streams Basics'),
                Tab(icon: Icon(Icons.fastfood), text: 'Fries Stream'),
              ],
            ),
          ),
          body: TabBarView(
            children: [const StreamBasics(), const FriesStreamHomePage()],
          ),
        ),
      ),
    );
  }
}
