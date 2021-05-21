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
  double _scale = 1.0;
  double _scalePrev = 1.0;
  late Offset _start;
  Offset _delta = Offset.zero;
  Offset _deltaPrev = Offset.zero;

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
          child = GestureDetector(
            onScaleStart: (details) {
              setState(() {
                _start = details.localFocalPoint;
              });
            },
            onScaleUpdate: (details) {
              final offset = details.localFocalPoint - _start;
              setState(() {
                _delta = offset / _scale + _deltaPrev;
                _scale = details.scale * _scalePrev;
              });
            },
            onScaleEnd: (details) {
              setState(() {
                _scalePrev = _scale;
                _deltaPrev = _delta;
              });
            },
            child: Container(
              width: image.width.toDouble(),
              height: image.height.toDouble(),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              child: Transform.translate(
                offset: _delta,
                child: Transform.scale(
                  scale: _scale,
                  origin: -_delta,
                  child: CustomPaint(
                    painter: DrawingPainter(image),
                  ),
                ),
              ),
            ),
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
  final ui.Image _image;
  DrawingPainter(this._image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(_image, Offset.zero, new Paint());
  }

  @override
  bool shouldRepaint(DrawingPainter old) {
    return old._image != this._image;
  }
}
