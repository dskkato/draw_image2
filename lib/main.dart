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
          title: Text('Draw sample2'),
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
  return codec.getNextFrame();
}

class _DrawingAreaState extends State<DrawingArea> {
  final TransformationController _transformationController =
      TransformationController();
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
          var image = snapshot.data!.image;
          child = InteractiveViewer(
            //boundaryMargin: const EdgeInsets.all(20.0),
            minScale: 0.1,
            maxScale: 5.0,
            //clipBehavior: Clip.none,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Colors.orange, Colors.red],
                      stops: <double>[0.0, 1.0],
                    ),
                  ),
                ),
                CustomPaint(
                  painter: DrawingPainter(image),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          child = Text('error occurred');
        } else {
          child = Text('waiting...');
        }
        print('$child');
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
