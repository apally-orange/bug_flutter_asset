import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<ByteData> resolveAsset() async {
    const key = 'assets/dark/flutter.jpg';
    ByteData? asset = await _getAssetsFromKey(key);
    const darkFolder = '/dark/';
    if (asset == null && key.contains(darkFolder)) {
      final lightKey = key.replaceAll(darkFolder, '/light/');
      asset = await _getAssetsFromKey(lightKey);
    }

    if (asset == null) {
      throw FlutterError('Unable to load asset: $key');
    }

    return asset;
  }

  Future<ByteData?> _getAssetsFromKey(String key) async {
    final Uint8List encoded = utf8.encoder.convert(
      Uri(
        path: Uri.encodeFull(key),
      ).path,
    );

    return await ServicesBinding.instance.defaultBinaryMessenger.send(
      'flutter/assets',
      encoded.buffer.asByteData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
                future: resolveAsset(),
                builder: (context, result) {
                  final safeData = result.data;
                  if (result.hasData && safeData != null) {
                    return Image.memory(
                      safeData.buffer.asUint8List(),
                      height: 250,
                    );
                  }

                  return const SizedBox.shrink();
                }),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
