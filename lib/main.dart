import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  MediaStream? _mediaStream;
  final List<RTCVideoRenderer> _renderers = [];

  void _addVideoStream() async {
    _mediaStream ??= await navigator.mediaDevices.getUserMedia({'video': true});

    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    renderer.srcObject = _mediaStream;
    _renderers.add(renderer);

    setState(() {});
  }

  void _removeVideoStream() async {
    if (_renderers.isEmpty) return;
    var renderer = _renderers.removeLast();
    renderer.srcObject = null;
    renderer.dispose();
    setState(() {});
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Number of video streams: ${_renderers.length}',
            ),
            Expanded(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemCount: _renderers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Center(
                      child: Column(
                        children: [
                          Center(child: Text('renderer index: $index')),
                          SizedBox(
                            width: 320,
                            height: 180,
                            child: Center(
                              child: RTCVideoView(_renderers[index]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: _addVideoStream,
            tooltip: 'Add',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: _removeVideoStream,
            tooltip: 'Remove',
            child: const Icon(Icons.remove),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
