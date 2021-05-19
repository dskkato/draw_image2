import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Draw sample'),
        ),
        body: DrawingArea());
  }
}

class DrawingArea extends StatefulWidget {
  @override
  _DrawingAreaState createState() => _DrawingAreaState();
}

Future<ui.FrameInfo> _loadImage(AssetBundle bundle, String path) async {
  final data = await bundle.load(path);
  final bytes = data.buffer.asUint8List();
  final codec = await ui.instantiateImageCodec(bytes);
  final frameInfo = await codec.getNextFrame();
  final buf = await frameInfo.image.toByteData();
  final buffer = buf!.buffer.asUint8List();
  final immutableBuffer = await ui.ImmutableBuffer.fromUint8List(buffer);
  final imageDescriptor = ui.ImageDescriptor.raw(immutableBuffer,
      width: 400, height: 600, pixelFormat: ui.PixelFormat.rgba8888);
  final codec2 = await imageDescriptor.instantiateCodec();
  return codec2.getNextFrame();
}

class _DrawingAreaState extends State<DrawingArea> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bundle = DefaultAssetBundle.of(context);
    return FutureBuilder<ui.FrameInfo>(
      future: _loadImage(bundle, 'assets/fruit.jpg'),
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.hasData) {
          child = CustomPaint(
            painter: DrawingPainter(snapshot.data!.image),
          );
        } else if (snapshot.hasError) {
          child = Text('error occurred');
        } else {
          child = Text('waiting...');
        }
        return child;
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final ui.Image image;
  DrawingPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, new Paint());
  }

  @override
  bool shouldRepaint(DrawingPainter old) {
    return old.image != this.image;
  }
}
