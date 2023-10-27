import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:dart_webrtc/src/media_stream_impl.dart';
import 'dart:ui_web';
import 'dart:html' as html;

void main() {
  runApp(const MyApp());
}

class VideoElementWeb extends StatefulWidget {
  final html.MediaStream src;
  final int id;
  final html.VideoElement videoElement = html.VideoElement();

  VideoElementWeb(this.src, this.id, {super.key});

  @override
  VideoElementWebState createState() => VideoElementWebState();
}

class VideoElementWebState extends State<VideoElementWeb> {
  @override
  void initState() {
    platformViewRegistry.registerViewFactory('video-el-web-${widget.id}',
        (int viewId) {
      final videoElement = widget.videoElement
        ..style.width = '100%'
        ..style.height = '100%'
        ..autoplay = true
        ..controls = false
        ..srcObject = widget.src;
      return videoElement;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: 'video-el-web-${widget.id}');
  }
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
  html.MediaStream? _mediaStream;
  int _counter = 0;

  void _addVideoStream() async {
    if (_mediaStream == null) {
      var fltStream =
          await navigator.mediaDevices.getUserMedia({'video': true});
      _mediaStream = (fltStream as MediaStreamWeb).jsStream;
    }
    setState(() {
      _counter++;
    });
  }

  void _removeVideoStream() async {
    if (_counter == 0) return;
    setState(() {
      _counter--;
    });
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
              'Number of video streams: $_counter',
            ),
            Expanded(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemCount: _counter,
                  itemBuilder: (BuildContext context, int index) {
                    return Center(
                      child: Column(
                        children: [
                          Center(child: Text('renderer index: $index')),
                          SizedBox(
                            width: 320,
                            height: 180,
                            child: Center(
                              child: VideoElementWeb(_mediaStream!, index),
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
      ),
    );
  }
}
